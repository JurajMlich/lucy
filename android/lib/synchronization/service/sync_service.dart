import 'package:android/model/server_instruction.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/sync_item.dart';

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
  Future<List<SyncItemRefreshResult>> refreshAll(ServerClient client);

  /// Refresh the item and return SyncItemRefreshResult. Do not crash in case
  /// of missing references, add this information to the result.
  Future<SyncItemRefreshResult> refreshOne(ServerClient client, ID identifier);

  /// todo(push): documentation
  Future<Null> sendInstruction(
    ServerClient client,
    ServerInstruction instruction,
  );
}
