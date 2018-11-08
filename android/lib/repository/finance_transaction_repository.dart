import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/repository.dart';
import 'package:android/utils/datetime_utils.dart';
import 'package:android/utils/enum_utils.dart';
import 'package:sqflite/sqflite.dart';

enum FinanceTransactionQueryExecutionDate {
  onlyFuture,
  maxCloseFuture,
  onlyPast,
  all,
}

enum FinanceTransactionQuerySort { newestToOldest, oldestToNewest }

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

  Future<List<FinanceTransaction>> findBy({
    int limit,
    int offset,
    List<FinanceTransactionState> onlyStates,
    FinanceTransactionQueryExecutionDate futureType =
        FinanceTransactionQueryExecutionDate.all,
    FinanceTransactionQuerySort sort = FinanceTransactionQuerySort.newestToOldest,
  }) async {
    var where = '';
    var whereArgs = <String>[];

    if (onlyStates != null) {
      where +=
          ' AND $columnState IN (${List.filled(onlyStates.length, '?').join(", ")})';
      onlyStates.forEach((state) => whereArgs.add(enumToString(state)));
    }

    if (futureType != FinanceTransactionQueryExecutionDate.all) {
      if (futureType == FinanceTransactionQueryExecutionDate.onlyFuture) {
        where += ' AND $columnExecutionDatetime > ?';
        whereArgs.add(dateTimeToInt(DateTime.now()).toString());
      } else if (futureType == FinanceTransactionQueryExecutionDate.onlyPast) {
        where += ' AND $columnExecutionDatetime < ?';
        whereArgs.add(dateTimeToInt(DateTime.now()).toString());
      } else if (futureType ==
          FinanceTransactionQueryExecutionDate.maxCloseFuture) {
        where += ' AND $columnExecutionDatetime < ?';
        whereArgs.add(
            dateTimeToInt(DateTime.now().add(Duration(days: 14))).toString());
      }
    }

    where = where.isEmpty ? null : where.substring(' AND'.length);

    var orderBy = '$columnExecutionDatetime '
        '${sort == FinanceTransactionQuerySort.newestToOldest ? 'DESC' : 'ASC'}';

    final results = await _database.query(
      tableName,
      columns: allColumns,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );

    return (await Future.wait(results.map((result) => convertFromMap(result))))
        .toList();
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
