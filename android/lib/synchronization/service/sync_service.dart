import 'dart:convert';

import 'package:android/model/server_instruction.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:http/http.dart';

abstract class SyncService<ID> {
  SyncItemType get forType;

  Future<Null> clearData();

  Future<List<SyncItemRefreshResult>> refreshAll(Client client);

  Future<SyncItemRefreshResult> refreshOne(Client client, ID identifier);

  Future<Null> sendInstruction(ServerInstruction instruction);

  // fixme: get rid of
  Future<String> fetch(Client client, String uri) async {
    // fixme: auth
    var response = await client.get('http://192.168.43.167:8080/$uri');
    return Utf8Decoder().convert(response.bodyBytes);
  }
}
