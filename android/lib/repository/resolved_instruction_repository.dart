import 'package:sqflite/sqflite.dart';

class ResolvedInstructionRepository {
  static const String tableName = 'resolved_instance_instruction';

  static const String columnId = 'id';

  final DatabaseExecutor _database;

  ResolvedInstructionRepository(DatabaseExecutor database) : _database = database;

  Future<Null> clear() async {
    await _database.delete(tableName);
  }

  Future<bool> isResolved(int id) async {
    var list = await _database.query(
      tableName,
      columns: ['count(*) as count'],
      where: '$columnId = ?',
      whereArgs: [id]
    );

    return list[0]['count'] > 0;
  }

  Future<Null> resolve(int id) async {
    await _database.insert(tableName, {
      columnId: id
    });
  }
}
