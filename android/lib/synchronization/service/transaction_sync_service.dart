import 'dart:convert';

import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/model/money_transaction.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:android/repository/money_transaction_repository.dart';
import 'package:android/repository/transaction_category_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/page_downloader.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:android/utils/string_utils.dart';

class TransactionSyncService extends SyncService<String> {
  DepositRepository _depositRepository;
  MoneyTransactionRepository _moneyTransactionRepository;
  UserRepository _userRepository;
  TransactionCategoryRepository _transactionCategoryRepository;

  @override
  SyncItemType get forType => SyncItemType.transaction;

  TransactionSyncService(
    this._depositRepository,
    this._userRepository,
    this._moneyTransactionRepository,
    this._transactionCategoryRepository,
  );

  @override
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  ) async {}

  Future<SyncItemRefreshResult> _processOne(dynamic rawData) async {
    var entity = await _moneyTransactionRepository.findById(rawData['id']);
    var creating = false;

    if (entity == null) {
      entity = MoneyTransaction(rawData['id']);
      creating = true;
    }

    entity
    ..executionDatetime = parseServerDateTime(rawData['executionDatetime'])
      ..sourceDepositId = rawData['sourceDepositId']
      ..targetDepositId = rawData['targetDepositId']
      ..state = stringToEnum<TransactionState>(
        TransactionState.values,
        underscoreToCamelCase(rawData['state']),
      )
      ..value = rawData['value']
      ..creatorId = rawData['creatorId']
      ..name = rawData['name']
      ..note = rawData['note']
      ..categoriesIds = Set();

    var missingSyncItems = Set<SyncItem>();

    for (var categoryId in rawData['categoriesIds']) {
      if ((await _transactionCategoryRepository.findById(categoryId)) == null) {
        missingSyncItems
            .add(SyncItem(SyncItemType.transactionCategory, categoryId));
      } else {
        entity.categoriesIds.add(categoryId);
      }
    }

    if ((await _userRepository.findById(entity.creatorId)) == null) {
      missingSyncItems.add(SyncItem(SyncItemType.user, entity.creatorId));
    }
    if (entity.sourceDepositId != null &&
        (await _depositRepository.findById(entity.sourceDepositId)) == null) {
      missingSyncItems
          .add(SyncItem(SyncItemType.deposit, entity.sourceDepositId));
    }
    if ((await _depositRepository.findById(entity.targetDepositId)) == null) {
      missingSyncItems
          .add(SyncItem(SyncItemType.deposit, entity.targetDepositId));
    }

    if (missingSyncItems.length > 0) {
      return SyncItemRefreshResult(SyncItem(SyncItemType.transaction, entity.id),
          SyncItemRefreshResultState.referenceMissing, missingSyncItems);
    }

    if (creating) {
      await _moneyTransactionRepository.create(entity);
    } else {
      await _moneyTransactionRepository.update(entity);
    }

    return SyncItemRefreshResult(
      SyncItem(
        SyncItemType.transaction,
        entity.id,
      ),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  Future<SyncItemRefreshResult> _deleteOne(String identifier) async {
    var deposit = await _moneyTransactionRepository.findById(identifier);

    if (deposit != null) {
      await _moneyTransactionRepository.delete(deposit);
    }

    return SyncItemRefreshResult(
      SyncItem(SyncItemType.transaction, identifier),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(
      ServerClient client, String identifier) async {
    try {
      var response = await client.get('transactions/$identifier');
      return await _processOne(jsonDecode(response.body));
    } on ForbiddenException {
      // if lost rights to see the item, delete it
      return await _deleteOne(identifier);
    } on NotFoundException {
      // if deleted on server, delete it here as well
      return await _deleteOne(identifier);
    }
  }

  @override
  Future<List<SyncItemRefreshResult>> refreshAll(ServerClient client) async {
    final result = List<SyncItemRefreshResult>();
    final pager = PageDownloader(client, 'transactions', 50);

    while (pager.hasNextPage()) {
      for (dynamic item in await pager.nextPage()) {
        result.add(await _processOne(item));
      }
    }

    for (dynamic id in pager.missingItemsIds) {
      result.add(await refreshOne(client, id));
    }

    return result;
  }

  @override
  Future<Null> clearData() async {
    await _moneyTransactionRepository.deleteAll();
  }
}
