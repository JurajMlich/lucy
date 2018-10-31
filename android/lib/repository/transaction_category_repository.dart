import 'package:android/model/transaction_category.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class TransactionCategoryRepository
    extends Repository<TransactionCategory, String> {
  static const String tableName = 'transaction_category';

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

  TransactionCategoryRepository(Database database)
      : super(
          database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<TransactionCategory> convertFromMap(Map<String, Object> data) async {
    return TransactionCategory(data[columnId])
      ..name = data[columnName]
      ..color = data[columnColor]
      ..disabled = data[columnDisabled] == 1
      ..negative = data[columnNegative] == 1;
  }

  @override
  Future<Map<String, Object>> convertToMap(TransactionCategory entity) async {
    return {
      columnId: entity.id,
      columnName: entity.name,
      columnColor: entity.color,
      columnDisabled: entity.disabled,
      columnNegative: entity.negative
    };
  }
}
