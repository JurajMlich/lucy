import 'dart:convert';

import 'package:android/model/server_instruction.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:http/http.dart';

/// Sync service for one SyncItemType used for refreshing data, so that they
/// are in sync with server.
abstract class SyncService<ID> {
  /// What type is this service for?
  SyncItemType get forType;

  /// Clear data (before full sync).
  Future<Null> clearData();

  /// Refresh all data (probably using some paging mechanism) and return list
  /// of SyncItemRefreshResult for each item refreshed. Do not crash in case
  /// of missing references, add this information to the result.
  Future<List<SyncItemRefreshResult>> refreshAll(Client client);

  /// Refresh the item and return SyncItemRefreshResult. Do not crash in case
  /// of missing references, add this information to the result.
  Future<SyncItemRefreshResult> refreshOne(Client client, ID identifier);

  /// todo(push): documentation
  Future<Null> sendInstruction(ServerInstruction instruction);

  // fixme: get rid of
  Future<String> fetch(Client client, String uri) async {
    // fixme: auth
    var response = await client.get('http://192.168.43.167:8080/$uri');
    return Utf8Decoder().convert(response.bodyBytes);
  }
}
