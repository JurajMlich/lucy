import 'package:android/model/deposit.dart';
import 'package:android/repository/repository.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:sqflite/sqflite.dart';

class DepositRepository extends Repository<Deposit, String> {
  static const String tableName = 'deposit';
  static const String tableNameOwner = 'deposit_owner';
  static const String tableNameAccessibleBy = 'deposit_accessible_by';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnBalance = 'balance';
  static const String columnDisabled = 'disabled';
  static const String columnType = 'type';

  static const String ownerColumnDepositId = 'deposit';
  static const String ownerColumnUserId = 'user';

  static const String accessibleByColumnDepositId = 'deposit';
  static const String accessibleByColumnUserId = 'user';

  static const List<String> allColumns = [
    columnId,
    columnName,
    columnBalance,
    columnDisabled,
    columnType,
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
    await _updateReferences(entity);
    return entity;
  }

  @override
  Future<Deposit> update(Deposit entity) async {
    entity = await super.update(entity);
    await _updateReferences(entity);
    return entity;
  }

  Future<Null> _updateReferences(Deposit entity) async {
    await _database.delete(tableNameOwner,
        where: '$ownerColumnDepositId = ?', whereArgs: [entity.id]);
    await _database.delete(tableNameAccessibleBy,
        where: '$accessibleByColumnDepositId = ?', whereArgs: [entity.id]);

    await Future.wait(entity.ownersIds.map(((ownerId) => _database.insert(
          tableNameOwner,
          {
            ownerColumnDepositId: entity.id,
            ownerColumnUserId: ownerId,
          },
        ))));

    await Future.wait(
        entity.accessibleByUsersIds.map(((ownerId) => _database.insert(
              tableNameAccessibleBy,
              {
                accessibleByColumnDepositId: entity.id,
                accessibleByColumnUserId: ownerId,
              },
            ))));
  }

  @override
  Future<Deposit> convertFromMap(Map<String, Object> data) async {
    var ownersRaw = await _database.query(
      tableNameOwner,
      columns: [ownerColumnUserId],
      where: '$ownerColumnDepositId = ?',
      whereArgs: [data[columnId]],
    );
    var ownersIds =
        Set<String>.from(ownersRaw.map((row) => row[ownerColumnUserId]));

    var accessibleByRaw = await _database.query(
      tableNameAccessibleBy,
      columns: [accessibleByColumnUserId],
      where: '$accessibleByColumnDepositId = ?',
      whereArgs: [data[columnId]],
    );
    var accessibleBy = Set<String>.from(
        accessibleByRaw.map((row) => row[accessibleByColumnUserId]));

    return Deposit(data[columnId])
      ..disabled = data[columnDisabled] == 1
      ..ownersIds = ownersIds
      ..accessibleByUsersIds = accessibleBy
      ..type = stringToEnum<DepositType>(DepositType.values, data[columnType])
      ..name = data[columnName]
      ..balance = data[columnBalance];
  }

  @override
  Future<Map<String, Object>> convertToMap(Deposit entity) async {
    return {
      columnId: entity.id,
      columnName: entity.name,
      columnBalance: entity.balance,
      columnDisabled: entity.disabled,
      columnType: enumToString(entity.type)
    };
  }
}
