import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
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

    migrations.add('''create table `${FinanceDepositRepository.tableName}` (
          ${FinanceDepositRepository.columnId} text primary key, 
          ${FinanceDepositRepository.columnName} text, 
          ${FinanceDepositRepository.columnDisabled} integer, 
          ${FinanceDepositRepository.columnType} text, 
          ${FinanceDepositRepository.columnBalance} real 
          )''');

    migrations.add('''create table `${FinanceDepositRepository.tableNameOwner}` (
          ${FinanceDepositRepository.ownerColumnUserId} text, 
          ${FinanceDepositRepository.ownerColumnDepositId} text
          )''');

    migrations
        .add('''create table `${FinanceDepositRepository.tableNameAccessibleBy}` (
          ${FinanceDepositRepository.accessibleByColumnUserId} text, 
          ${FinanceDepositRepository.accessibleByColumnDepositId} text
          )''');

    migrations
        .add('''create table `${ResolvedInstructionRepository.tableName}` (
          ${ResolvedInstructionRepository.columnId} integer primary key
          )''');

    migrations.add('''create table `${FinanceTransactionRepository.tableName}` (
          ${FinanceTransactionRepository.columnId} text primary key, 
          ${FinanceTransactionRepository.columnSourceDepositId} text, 
          ${FinanceTransactionRepository.columnTargetDepositId} text, 
          ${FinanceTransactionRepository.columnState} text, 
          ${FinanceTransactionRepository.columnValue} real, 
          ${FinanceTransactionRepository.columnExecutionDatetime} integer, 
          ${FinanceTransactionRepository.columnCreatorId} text, 
          ${FinanceTransactionRepository.columnName} text, 
          ${FinanceTransactionRepository.columnNote} text
          )''');

    migrations.add(
        '''create table `${FinanceTransactionRepository.tableNameCategories}` (
          ${FinanceTransactionRepository.categoriesColumnTransactionId} text, 
          ${FinanceTransactionRepository.categoriesColumnCategoryId} text
          )''');

    migrations
        .add('''create table `${FinanceTransactionCategoryRepository.tableName}` (
          ${FinanceTransactionCategoryRepository.columnId} text primary key, 
          ${FinanceTransactionCategoryRepository.columnName} text, 
          ${FinanceTransactionCategoryRepository.columnColor} text, 
          ${FinanceTransactionCategoryRepository.columnNegative} integer, 
          ${FinanceTransactionCategoryRepository.columnDisabled} integer
          )''');

    // todo: non null
    // todo: indexes and foreign keys
  }

  return migrations;
}
