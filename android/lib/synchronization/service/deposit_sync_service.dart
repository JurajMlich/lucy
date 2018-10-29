import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/model/deposit.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:http/http.dart';

class DepositSyncService extends SyncService<String> {
  DepositRepository _depositRepository;
  UserRepository _userRepository;

  @override
  SyncItemType get forType => SyncItemType.deposit;

  DepositSyncService(this._depositRepository, this._userRepository);

  @override
  Future<Null> sendInstruction(ServerInstruction instruction) async {}

  Future<SyncItemRefreshResult> processOne(dynamic rawDeposit) async {
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
      SyncItemRefreshResultState.synchronized,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(
      Client client, String identifier) async {
    var response = await fetch(client, 'deposits/$identifier');
    return await processOne(jsonDecode(response));
  }

  @override
  Future<List<SyncItemRefreshResult>> refreshAll(Client client) async {
    final ids = (await downloadIds(client)).toList();
    final result = List<SyncItemRefreshResult>();

    var pages = 0;
    var page = 0;
    do {
      var response = FindDto.fromJson(
        jsonDecode(
          await fetch(client, 'deposits?page=$page&size=1'),
        ),
      );

      for (dynamic item in response.content) {
        result.add(await processOne(item));
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

  Future<List<String>> downloadIds(Client client) async {
    var response = await fetch(client, 'deposits/ids');
    return List<String>.from(jsonDecode(response), growable: false);
  }

  @override
  Future<Null> clearData() async {
    await _depositRepository.deleteAll();
  }
}
