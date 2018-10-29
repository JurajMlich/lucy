import 'package:android/model/deposit.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class DepositRepository extends Repository<Deposit, String> {
  static const String tableName = 'deposit';

  static const String columnId = 'id';
  static const String columnOwnerId = 'owner_id';
  static const String columnName = 'name';
  static const String columnBalance = 'balance';
  static const List<String> allColumns = [
    columnId,
    columnOwnerId,
    columnName,
    columnBalance,
  ];

  DepositRepository(Database database)
      : super(
          database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Deposit convertFromMap(Map<String, Object> data) {
    return Deposit(data[columnId])
      ..ownerId = data[columnOwnerId]
      ..name = data[columnName]
      ..balance = data[columnBalance];
  }

  @override
  Map<String, Object> convertToMap(Deposit entity) {
    return {
      columnId: entity.id,
      columnOwnerId: entity.ownerId,
      columnName: entity.name,
      columnBalance: entity.balance,
    };
  }
}
