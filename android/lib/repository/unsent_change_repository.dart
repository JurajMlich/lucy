import 'package:android/model/server_instruction.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class PendingChangeRepository extends Repository<ServerInstruction, int> {
  static const String tableName = 'pending_change';

  static const String columnId = 'id';
  static const String columnType = 'type';
  static const String columnData = 'data';
  static const String columnDateTime = 'date_time';

  PendingChangeRepository(Database database)
      : super(
          database,
          tableName,
          columnId,
          [
            columnId,
            columnType,
            columnData,
            columnDateTime,
          ],
        );

  @override
  Future<ServerInstruction> convertFromMap(Map<String, Object> data) async {
    return ServerInstruction()
      ..id = data[columnId]
      ..dateTime = DateTime.fromMillisecondsSinceEpoch(data[columnDateTime])
      ..data = data[columnData]
      ..type = data[columnType];
  }

  @override
  Future<Map<String, Object>> convertToMap(ServerInstruction entity) async {
    return {
      columnId: entity.id,
      columnType: entity.type,
      columnDateTime: entity.dateTime.millisecondsSinceEpoch,
      columnData: entity.data,
    };
  }
}
