import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/executor/user_sync_executor.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

class SyncManager {
  final UserSyncExecutor _userSyncExecutor;

  SyncManager(Database database)
      : _userSyncExecutor = UserSyncExecutor(UserRepository(database));

  Future<Null> synchronize() async {
    final client = Client();
//
//    List<PendingChange> operations = List();
//    operations.map((PendingChange operation) {
//      switch (operation.type) {
//        case DepositCreateOperation.identifier:
//          return DepositCreateOperation.fromJson(jsonDecode(operation.data));
//          break;
//        case DepositUpdateOperation.identifier:
//          return DepositUpdateOperation.fromJson(jsonDecode(operation.data));
//          break;
//      }
//    }).forEach((operation) {
//      _userSyncExecutor.doPush(client, operation);
//    });

    var ids = await _userSyncExecutor.downloadIds(client);
    var data = await _userSyncExecutor.downloadData(client, 0, 10);
    var test = await _userSyncExecutor.downloadOne(client, "5d68b2cd-cfa0-47ba-96ef-da7a25154197");
    for (var value in data.content) {
      await _userSyncExecutor.process(value);
    }
    print(ids);
  }
}
