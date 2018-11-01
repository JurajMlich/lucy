import 'package:android/model/id_aware.dart';
import 'package:sqflite/sqflite.dart';

abstract class Repository<T extends IdAware<ID>, ID> {
  List<String> _columns;

  String _tableName;

  String _idColumn;

  Database _database;

  Repository(this._database, this._tableName, this._idColumn, this._columns);

  Future<T> create(T entity) async {
    Object id = await _database.insert(_tableName, await convertToMap(entity));

    if (id is ID) {
      entity.id = id;
    }

    return entity;
  }

  Future<T> update(T entity) async {
    await _database.update(
      _tableName,
      await convertToMap(entity),
      where: '$_idColumn = ?',
      whereArgs: <Object>[entity.id],
    );
    return entity;
  }

  Future<void> delete(T entity) async {
    await _database.delete(
      _tableName,
      where: '$_idColumn = ?',
      whereArgs: <Object>[entity.id],
    );
  }

  Future<List<T>> findAll({
    int limit,
    int offset,
  }) async {
    final results = await _database.query(
      _tableName,
      columns: _columns,
      limit: limit,
      offset: offset,
    );

    return (await Future.wait(results.map((result) => convertFromMap(result))))
        .toList();
  }

  Future<Null> deleteAll() async {
    _database.delete(_tableName);
  }

  Future<T> findById(ID id) async {
    final results = await _database.query(
      _tableName,
      columns: _columns,
      where: '$_idColumn = ?',
      whereArgs: <Object>[id],
    );

    if (results.isNotEmpty) {
      return convertFromMap(results.first);
    }
    return null;
  }

  Future<T> convertFromMap(Map<String, Object> data);

  Future<Map<String, Object>> convertToMap(T entity);
}
