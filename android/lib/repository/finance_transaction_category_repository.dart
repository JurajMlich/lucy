import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class FinanceTransactionCategoryRepository
    extends Repository<FinanceTransactionCategory, String> {
  static const String tableName = 'finance_transaction_category';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnColor = 'color';
  static const String columnNegative = 'negative';
  static const String columnDisabled = 'disabled';

  static const List<String> allColumns = [
    columnId,
    columnName,
    columnColor,
    columnNegative,
    columnDisabled
  ];

  FinanceTransactionCategoryRepository(Database database)
      : super(
          database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<FinanceTransactionCategory> convertFromMap(
      Map<String, Object> data) async {
    return FinanceTransactionCategory(data[columnId])
      ..name = data[columnName]
      ..color = data[columnColor]
      ..disabled = data[columnDisabled] == 1
      ..negative = data[columnNegative] == 1;
  }

  @override
  Future<Map<String, Object>> convertToMap(
      FinanceTransactionCategory entity) async {
    return {
      columnId: entity.id,
      columnName: entity.name,
      columnColor: entity.color,
      columnDisabled: entity.disabled,
      columnNegative: entity.negative
    };
  }
}
