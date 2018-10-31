import 'package:android/repository/deposit_repository.dart';
import 'package:android/repository/money_transaction_repository.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/repository/transaction_category_repository.dart';
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

    migrations.add('''create table `${DepositRepository.tableName}` (
          ${DepositRepository.columnId} text primary key, 
          ${DepositRepository.columnName} text, 
          ${DepositRepository.columnDisabled} integer, 
          ${DepositRepository.columnType} text, 
          ${DepositRepository.columnBalance} real 
          )''');

    migrations.add('''create table `${DepositRepository.tableNameOwner}` (
          ${DepositRepository.ownerColumnUserId} text primary key, 
          ${DepositRepository.ownerColumnDepositId} text
          )''');

    migrations
        .add('''create table `${DepositRepository.tableNameAccessibleBy}` (
          ${DepositRepository.accessibleByColumnUserId} text primary key, 
          ${DepositRepository.accessibleByColumnDepositId} text
          )''');

    migrations
        .add('''create table `${ResolvedInstructionRepository.tableName}` (
          ${ResolvedInstructionRepository.columnId} integer primary key
          )''');

    migrations.add('''create table `${MoneyTransactionRepository.tableName}` (
          ${MoneyTransactionRepository.columnId} text primary key, 
          ${MoneyTransactionRepository.columnSourceDepositId} text, 
          ${MoneyTransactionRepository.columnTargetDepositId} text, 
          ${MoneyTransactionRepository.columnState} text, 
          ${MoneyTransactionRepository.columnValue} real, 
          ${MoneyTransactionRepository.columnExecutionDatetime} integer, 
          ${MoneyTransactionRepository.columnCreatorId} text, 
          ${MoneyTransactionRepository.columnName} text, 
          ${MoneyTransactionRepository.columnNote} text
          )''');

    migrations.add(
        '''create table `${MoneyTransactionRepository.tableNameCategories}` (
          ${MoneyTransactionRepository.categoriesColumnTransactionId} text primary key, 
          ${MoneyTransactionRepository.categoriesColumnCategoryId} text
          )''');

    migrations
        .add('''create table `${TransactionCategoryRepository.tableName}` (
          ${TransactionCategoryRepository.columnId} text primary key, 
          ${TransactionCategoryRepository.columnName} text, 
          ${TransactionCategoryRepository.columnColor} text, 
          ${TransactionCategoryRepository.columnNegative} integer, 
          ${TransactionCategoryRepository.columnDisabled} integer
          )''');

    // todo: non null
    // todo: indexes and foreign keys
  }

  return migrations;
}
