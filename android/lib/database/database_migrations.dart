import 'package:android/repository/unsent_change_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:meta/meta.dart';

List<String> buildMigrations({int oldVersion, @required int newVersion}) {
  var migrations = new List<String>();

  if (oldVersion == null || oldVersion == 0) {
    migrations.add('''create table `${UserRepository.tableName}` (
          ${UserRepository.columnId} text primary key, 
          ${UserRepository.columnEmail} text, 
          ${UserRepository.columnFirstName} text, 
          ${UserRepository.columnLastName} text 
          )''');

    migrations.add('''create table `${PendingChangeRepository.tableName}` (
          ${PendingChangeRepository.columnId} integer primary key autoincrement, 
          ${PendingChangeRepository.columnType} text, 
          ${PendingChangeRepository.columnData} text, 
          ${PendingChangeRepository.columnDateTime} integer 
          )''');
  }

  return migrations;
}
