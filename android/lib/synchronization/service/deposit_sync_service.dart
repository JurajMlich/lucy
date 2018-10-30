import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/model/deposit.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';

class DepositSyncService extends SyncService<String> {
  DepositRepository _depositRepository;
  UserRepository _userRepository;

  @override
  SyncItemType get forType => SyncItemType.deposit;

  DepositSyncService(this._depositRepository, this._userRepository);

  @override
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  ) async {}

  Future<SyncItemRefreshResult> _processOne(dynamic rawDeposit) async {
    var deposit = await _depositRepository.findById(rawDeposit['id']);
    var creating = false;

    if (deposit == null) {
      deposit = Deposit(rawDeposit['id']);
      creating = true;
    }

    deposit
      ..name = rawDeposit['name']
      ..ownerId = rawDeposit['ownerId']
      ..balance = rawDeposit['balance'];

    if ((await _userRepository.findById(deposit.ownerId)) == null) {
      return SyncItemRefreshResult(
        SyncItem(SyncItemType.deposit, deposit.id),
        SyncItemRefreshResultState.referenceMissing,
        Set.from([SyncItem(SyncItemType.user, deposit.ownerId)]),
      );
    }

    if (creating) {
      await _depositRepository.create(deposit);
    } else {
      await _depositRepository.update(deposit);
    }

    return SyncItemRefreshResult(
      SyncItem(
        SyncItemType.deposit,
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
      SyncItem(SyncItemType.deposit, identifier),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(
      ServerClient client, String identifier) async {
    try {
      var response = await client.get('deposits/$identifier');
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
    final ids = (await downloadIds(client)).toList();
    final result = List<SyncItemRefreshResult>();

    var pages = 0;
    var page = 0;
    do {
      var response = FindDto.fromJson(
        jsonDecode(
          (await client.get('deposits?page=$page&size=1')).body,
        ),
      );

      for (dynamic item in response.content) {
        result.add(await _processOne(item));
        if (ids.contains(item['id'])) {
          ids.remove(item['id']);
        }
      }

      pages = response.totalPages;
      page++;
    } while (page < pages);

    for (String id in ids) {
      result.add(await refreshOne(client, id));
    }

    return result;
  }

  Future<List<String>> downloadIds(ServerClient client) async {
    var response = await client.get('deposits/ids');
    return List<String>.from(jsonDecode(response.body), growable: false);
  }

  @override
  Future<Null> clearData() async {
    await _depositRepository.deleteAll();
  }
}
