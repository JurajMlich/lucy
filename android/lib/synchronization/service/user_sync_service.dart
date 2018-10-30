import 'dart:convert';

import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/model/user.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/page_downloader.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';

class UserSyncService extends SyncService<String> {
  UserRepository _userRepository;

  @override
  SyncItemType get forType => SyncItemType.user;

  UserSyncService(this._userRepository);

  @override
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  ) async {}

  Future<SyncItemRefreshResult> _processOne(dynamic rawUser) async {
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

  Future<SyncItemRefreshResult> _deleteOne(String identifier) async {
    var user = await _userRepository.findById(identifier);

    if (user != null) {
      await _userRepository.delete(user);
    }

    return SyncItemRefreshResult(
      SyncItem(SyncItemType.user, identifier),
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
      var response = await client.get('users/$identifier');
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
    final pager = PageDownloader(client, 'users', 50);

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
    await _userRepository.deleteAll();
  }
}
