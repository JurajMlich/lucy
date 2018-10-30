import 'package:android/model/deposit.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class DepositRepository extends Repository<Deposit, String> {
  static const String tableName = 'deposit';
  static const String tableNameOwner = 'deposit_owner';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnBalance = 'balance';

  static const String ownerColumnDepositId = 'deposit';
  static const String ownerColumnUserId = 'user';

  static const List<String> allColumns = [
    columnId,
    columnName,
    columnBalance,
  ];

  final Database _database;

  DepositRepository(this._database)
      : super(
          _database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<Deposit> create(Deposit entity) async {
    entity = await super.create(entity);
    await _updateOwners(entity);
    return entity;
  }

  @override
  Future<Deposit> update(Deposit entity) async {
    entity = await super.update(entity);
    await _updateOwners(entity);
    return entity;
  }

  Future<Null> _updateOwners(Deposit entity) async {
    await _database.delete(tableNameOwner,
        where: '$ownerColumnDepositId = ?', whereArgs: [entity.id]);

    for (var ownerId in entity.ownersIds) {
      await _database.insert(
        tableNameOwner,
        {
          ownerColumnDepositId: entity.id,
          ownerColumnUserId: ownerId,
        },
      );
    }
  }

  @override
  Future<Deposit> convertFromMap(Map<String, Object> data) async {
    var ownersRaw = await _database.query(
      tableNameOwner,
      columns: [ownerColumnUserId],
      where: '$ownerColumnDepositId = ?',
      whereArgs: [ownerColumnDepositId],
    );
    var ownersIds =
        Set<String>.from(ownersRaw.map((row) => row[ownerColumnUserId]));

    return Deposit(data[columnId])
      ..ownersIds = ownersIds
      ..name = data[columnName]
      ..balance = data[columnBalance];
  }

  @override
  Future<Map<String, Object>> convertToMap(Deposit entity) async {
    return {
      columnId: entity.id,
      columnName: entity.name,
      columnBalance: entity.balance,
    };
  }
}
