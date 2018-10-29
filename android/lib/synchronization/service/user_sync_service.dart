import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/model/user.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:http/http.dart';

class UserSyncService extends SyncService<String> {
  UserRepository _userRepository;

  @override
  SyncItemType get forType => SyncItemType.user;

  UserSyncService(this._userRepository);

  @override
  Future<Null> sendInstruction(ServerInstruction instruction) async {}

  Future<SyncItemRefreshResult> processOne(dynamic rawUser) async {
    var user = await _userRepository.findById(rawUser['id']);
    var creating = false;

    if (user == null) {
      user = User(rawUser['id']);
      creating = true;
    }

    user
      ..email = rawUser['email']
      ..firstName = rawUser['firstName']
      ..lastName = rawUser['lastName'];

    if (creating) {
      await _userRepository.create(user);
    } else {
      await _userRepository.update(user);
    }

    return SyncItemRefreshResult(
      SyncItem(
        SyncItemType.user,
        user.id,
      ),
      SyncItemRefreshResultState.refreshed,
      Set(),
    );
  }

  @override
  Future<SyncItemRefreshResult> refreshOne(Client client, String identifier) async {
    var response = await fetch(client, 'users/$identifier');
    return await processOne(jsonDecode(response));
  }

  @override
  Future<List<SyncItemRefreshResult>> refreshAll(Client client) async {
    // todo abstract this
    final ids = (await downloadIds(client)).toList();
    final result = List<SyncItemRefreshResult>();

    var pages = 0;
    var page = 0;
    do {
      var response = FindDto.fromJson(
        jsonDecode(
          await fetch(client, 'users?page=$page&size=1'),
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
    var response = await fetch(client, 'users/ids');
    return List<String>.from(jsonDecode(response), growable: false);
  }

  @override
  Future<Null> clearData() async {
    await _userRepository.deleteAll();
  }
}
