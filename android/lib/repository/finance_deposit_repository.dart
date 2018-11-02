import 'package:android/model/finance_deposit.dart';
import 'package:android/repository/repository.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:sqflite/sqflite.dart';

class FinanceDepositRepository extends Repository<FinanceDeposit, String> {
  static const String tableName = 'finance_deposit';
  static const String tableNameOwner = 'finance_deposit_owner';
  static const String tableNameAccessibleBy = 'finance_deposit_accessible_by';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnBalance = 'balance';
  static const String columnMinBalance = 'min_balance';
  static const String columnDisabled = 'disabled';
  static const String columnType = 'type';

  static const String ownerColumnDepositId = 'finance_deposit_id';
  static const String ownerColumnUserId = 'user_id';

  static const String accessibleByColumnDepositId = 'finance_deposit_id';
  static const String accessibleByColumnUserId = 'user';

  static const List<String> allColumns = [
    columnId,
    columnName,
    columnBalance,
    columnMinBalance,
    columnDisabled,
    columnType,
  ];

  final Database _database;

  FinanceDepositRepository(this._database)
      : super(
          _database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<FinanceDeposit> create(FinanceDeposit entity) async {
    entity = await super.create(entity);
    await _updateReferences(entity);
    return entity;
  }

  @override
  Future<FinanceDeposit> update(FinanceDeposit entity) async {
    entity = await super.update(entity);
    await _updateReferences(entity);
    return entity;
  }

  Future<Null> _updateReferences(FinanceDeposit entity) async {
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
  Future<FinanceDeposit> convertFromMap(Map<String, Object> data) async {
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

    return FinanceDeposit(data[columnId])
      ..disabled = data[columnDisabled] == 1
      ..ownersIds = ownersIds
      ..accessibleByUsersIds = accessibleBy
      ..type = stringToEnum<FinanceDepositType>(
          FinanceDepositType.values, data[columnType])
      ..name = data[columnName]
      ..balance = data[columnBalance]
      ..minBalance = data[columnMinBalance];
  }

  @override
  Future<Map<String, Object>> convertToMap(FinanceDeposit entity) async {
    return {
      columnId: entity.id,
      columnName: entity.name,
      columnBalance: entity.balance,
      columnMinBalance: entity.minBalance,
      columnDisabled: entity.disabled,
      columnType: enumToString(entity.type)
    };
  }
}
