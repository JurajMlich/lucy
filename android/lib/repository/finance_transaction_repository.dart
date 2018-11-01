import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/repository.dart';
import 'package:android/utils/datetime_utils.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:sqflite/sqflite.dart';

class FinanceTransactionRepository
    extends Repository<FinanceTransaction, String> {
  static const String tableName = 'finance_transaction';
  static const String tableNameCategories =
      'finance_transaction_transaction_category';

  static const String columnId = 'id';
  static const String columnSourceDepositId = 'source_deposit_id';
  static const String columnTargetDepositId = 'target_deposit_id';
  static const String columnState = 'state';
  static const String columnValue = 'value';
  static const String columnExecutionDatetime = 'execution_datetime';
  static const String columnCreatorId = 'creator_id';
  static const String columnName = 'name';
  static const String columnNote = 'note';

  static const String categoriesColumnTransactionId = 'transaction_id';
  static const String categoriesColumnCategoryId = 'category_id';

  static const List<String> allColumns = [
    columnId,
    columnSourceDepositId,
    columnTargetDepositId,
    columnState,
    columnValue,
    columnExecutionDatetime,
    columnCreatorId,
    columnName,
    columnNote
  ];

  final Database _database;

  FinanceTransactionRepository(this._database)
      : super(
          _database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<FinanceTransaction> create(FinanceTransaction entity) async {
    entity = await super.create(entity);
    await _updateReferences(entity);
    return entity;
  }

  @override
  Future<FinanceTransaction> update(FinanceTransaction entity) async {
    entity = await super.update(entity);
    await _updateReferences(entity);
    return entity;
  }

  Future<Null> _updateReferences(FinanceTransaction entity) async {
    await _database.delete(tableNameCategories,
        where: '$categoriesColumnTransactionId = ?', whereArgs: [entity.id]);

    await Future.wait(
        entity.categoriesIds.map(((categoryId) => _database.insert(
              tableNameCategories,
              {
                categoriesColumnTransactionId: entity.id,
                categoriesColumnCategoryId: categoryId,
              },
            ))));
  }

  @override
  Future<FinanceTransaction> convertFromMap(Map<String, Object> data) async {
    var categoriesRaw = await _database.query(
      tableNameCategories,
      columns: [categoriesColumnCategoryId],
      where: '$categoriesColumnTransactionId = ?',
      whereArgs: [data[columnId]],
    );
    var categoriesIds = Set<String>.from(
        categoriesRaw.map((row) => row[categoriesColumnCategoryId]));

    // ..executionDatetime =
    return FinanceTransaction(data[columnId])
      ..categoriesIds = categoriesIds
      ..value = data[columnValue]
      ..name = data[columnName]
      ..state = stringToEnum(FinanceTransactionState.values, data[columnState])
      ..creatorId = data[columnCreatorId]
      ..note = data[columnNote]
      ..sourceDepositId = data[columnSourceDepositId]
      ..targetDepositId = data[columnTargetDepositId]
      ..executionDatetime = intToDateTime(data[columnExecutionDatetime]);
  }

  @override
  Future<Map<String, Object>> convertToMap(FinanceTransaction entity) async {
    return {
      columnId: entity.id,
      columnExecutionDatetime: dateTimeToInt(entity.executionDatetime),
      columnTargetDepositId: entity.targetDepositId,
      columnSourceDepositId: entity.sourceDepositId,
      columnNote: entity.note,
      columnCreatorId: entity.creatorId,
      columnState: enumToString(entity.state),
      columnName: entity.name,
      columnValue: entity.value,
    };
  }
}
