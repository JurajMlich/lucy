import 'dart:convert';

import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/model/transaction_category.dart';
import 'package:android/repository/transaction_category_repository.dart';
import 'package:android/synchronization/page_downloader.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';

class TransactionCategorySyncService extends SyncService<String> {
  TransactionCategoryRepository _transactionCategoryRepository;

  @override
  SyncItemType get forType => SyncItemType.transactionCategory;

  TransactionCategorySyncService(this._transactionCategoryRepository);

  @override
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  ) async {}

  Future<SyncItemRefreshResult> _processOne(dynamic rawData) async {
    var transactionCategory =
        await _transactionCategoryRepository.findById(rawData['id']);
    var creating = false;

    if (transactionCategory == null) {
      transactionCategory = TransactionCategory(rawData['id']);
      creating = true;
    }

    transactionCategory
      ..negative = rawData['negative']
      ..disabled = rawData['disabled']
      ..color = rawData['color']
      ..name = rawData['name'];

    if (creating) {
      await _transactionCategoryRepository.create(transactionCategory);
    } else {
      await _transactionCategoryRepository.update(transactionCategory);
    }

    return SyncItemRefreshResult(
      SyncItem(
        SyncItemType.transactionCategory,
        transactionCategory.id,
      ),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  Future<SyncItemRefreshResult> _deleteOne(String identifier) async {
    var transactionCategory =
        await _transactionCategoryRepository.findById(identifier);

    if (transactionCategory != null) {
      await _transactionCategoryRepository.delete(transactionCategory);
    }

    return SyncItemRefreshResult(
      SyncItem(SyncItemType.transactionCategory, identifier),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(
    ServerClient client,
    String identifier,
  ) async {
    try {
      var response = await client.get('transactionCategories/$identifier');
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
    final pager = PageDownloader(client, 'transactionCategories', 50);

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
    await _transactionCategoryRepository.deleteAll();
  }
}
