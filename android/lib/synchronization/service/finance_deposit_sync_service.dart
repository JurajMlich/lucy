import 'dart:convert';

import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/model/deposit.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/page_downloader.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:android/utils/string_utils.dart';

class FinanceDepositSyncService extends SyncService<String> {
  FinanceDepositRepository _depositRepository;
  UserRepository _userRepository;

  @override
  SyncItemType get forType => SyncItemType.financeDeposit;

  FinanceDepositSyncService(this._depositRepository, this._userRepository);

  @override
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  ) async {}

  Future<SyncItemRefreshResult> _processOne(dynamic rawDeposit) async {
    var deposit = await _depositRepository.findById(rawDeposit['id']);
    var creating = false;

    if (deposit == null) {
      deposit = FinanceDeposit(rawDeposit['id']);
      creating = true;
    }

    deposit
      ..name = rawDeposit['name']
      ..ownersIds = Set()
      ..accessibleByUsersIds = Set()
      ..balance = rawDeposit['balance']
      ..disabled = rawDeposit['disabled']
      ..type = stringToEnum(
        FinanceDepositType.values,
        underscoreToCamelCase(rawDeposit['type']),
      );

    var missingSyncItems = Set<SyncItem>();

    for (var ownerId in rawDeposit['ownersIds']) {
      if ((await _userRepository.findById(ownerId)) == null) {
        missingSyncItems.add(SyncItem(SyncItemType.user, ownerId));
      } else {
        deposit.ownersIds.add(ownerId);
      }
    }

    for (var userId in rawDeposit['accessibleByUsersIds']) {
      if ((await _userRepository.findById(userId)) == null) {
        missingSyncItems.add(SyncItem(SyncItemType.user, userId));
      } else {
        deposit.accessibleByUsersIds.add(userId);
      }
    }

    if (missingSyncItems.length > 0) {
      return SyncItemRefreshResult(SyncItem(SyncItemType.financeDeposit, deposit.id),
          SyncItemRefreshResultState.referenceMissing, missingSyncItems);
    }

    if (creating) {
      await _depositRepository.create(deposit);
    } else {
      await _depositRepository.update(deposit);
    }

    return SyncItemRefreshResult(
      SyncItem(
        SyncItemType.financeDeposit,
        deposit.id,
      ),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  Future<SyncItemRefreshResult> _deleteOne(String identifier) async {
    var deposit = await _depositRepository.findById(identifier);

    if (deposit != null) {
      await _depositRepository.delete(deposit);
    }

    return SyncItemRefreshResult(
      SyncItem(SyncItemType.financeDeposit, identifier),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(
      ServerClient client, String identifier) async {
    try {
      var response = await client.get('financeDeposits/$identifier');
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
    final pager = PageDownloader(client, 'financeDeposits', 50);

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
    await _depositRepository.deleteAll();
  }
}
