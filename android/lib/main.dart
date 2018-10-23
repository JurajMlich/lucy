import 'package:android/database/database_migrations.dart';
import 'package:android/lucy_app.dart';
import 'package:android/redux/store.dart';
import 'package:android/synchronization/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  Database database = await _prepareDatabase();
  SyncManager syncManager = await _prepareSyncManager(database);

  final store = await createStore(database, syncManager);

  runApp(LucyApp(store));
}

Future<SyncManager> _prepareSyncManager(Database database) async {
  return SyncManager(database);
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
