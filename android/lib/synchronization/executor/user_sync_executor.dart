import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/model/server_instruction.dart';
import 'package:android/model/user.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/executor/sync_executor.dart';
import 'package:http/http.dart';

class UserSyncExecutor extends SyncExecutor<String> {
  static const String resourceName = 'user';

  UserRepository _userRepository;

  UserSyncExecutor(this._userRepository);

  @override
  Future<Null> sendInstruction(ServerInstruction instruction) async {}

  @override
  Future<Null> process(dynamic rawUser) async {
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
  }

  @override
  Future<dynamic> downloadOne(Client client, String identifier) async {
    var response = await fetch(client, 'users/$identifier');
    return jsonDecode(response);
  }

  @override
  Future<FindDto> downloadData(
      Client client, int page) async {
    var response = await fetch(client, 'users?page=$page&size=1');
    return FindDto.fromJson(jsonDecode(response));
  }

  @override
  Future<List<String>> downloadIds(Client client) async {
    var response = await fetch(client, 'users/ids');
    return List<String>.from(jsonDecode(response), growable: false);
  }
}
