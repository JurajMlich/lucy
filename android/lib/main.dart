import 'package:android/database/database_migrations.dart';
import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/lucy_app.dart';
import 'package:android/redux/store.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/service/deposit_sync_service.dart';
import 'package:android/synchronization/service/user_sync_service.dart';
import 'package:android/synchronization/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  var sharedPreferences = await SharedPreferences.getInstance();

  Database database = await _prepareDatabase();
  SyncManager syncManager = await _prepareSyncManager(
    sharedPreferences,
    database,
  );

  final store = await createStore(database, syncManager);

  runApp(LucyApp(store));
}

Future<SyncManager> _prepareSyncManager(
  SharedPreferences sharedPreferences,
  Database database,
) async {
  var depositRepository = DepositRepository(database);
  var userRepository = UserRepository(database);

  return SyncManager(
    sharedPreferences,
    ResolvedInstructionRepository(database),
    [
      DepositSyncService(depositRepository, userRepository),
      UserSyncService(userRepository),
    ],
  );
}

Future<Database> _prepareDatabase() async {
  final appDir = await getApplicationDocumentsDirectory();
  final database = await openDatabase(
      join(
        appDir.path,
        'database.db',
      ),
      version: 1,
      onConfigure: (db) async => await db.execute("PRAGMA foreign_keys = ON"),
      onUpgrade: (db, oldVersion, newVersion) => null,
      onCreate: (db, version) async {
        var migrations = buildMigrations(newVersion: version);
        for (var query in migrations) {
          await db.execute(query);
        }
      });
  return database;
}
