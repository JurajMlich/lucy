import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/model/server_instruction.dart';
import 'package:http/http.dart';

abstract class SyncExecutor<ID> {
  Future<List<ID>> downloadIds(Client client);

  Future<FindDto> downloadData(Client client, int page, int pageSize);

  Future<dynamic> downloadOne(Client client, ID identifier);

  Future<Null> process(dynamic item);

  Future<Null> sendInstruction(ServerInstruction instruction);

  // fixme: get rid of
  Future<String> fetch(Client client, String uri) async {
    // fixme: auth
    var response = await client.get('http://192.168.1.35:8080/$uri');
    return Utf8Decoder().convert(response.bodyBytes);
  }
}
