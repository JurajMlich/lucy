import 'package:android/model/user.dart';
import 'package:android/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository extends Repository<User, String> {
  static const String tableName = 'user';

  static const String columnId = 'id';
  static const String columnEmail = 'email';
  static const String columnFirstName = 'first_name';
  static const String columnLastName = 'last_name';
  static const List<String> allColumns = [
    columnId,
    columnEmail,
    columnFirstName,
    columnLastName,
  ];

  UserRepository(Database database)
      : super(
          database,
          tableName,
          columnId,
          allColumns,
        );

  @override
  Future<User> convertFromMap(Map<String, Object> data) async {
    return User(data[columnId])
      ..email = data[columnEmail]
      ..firstName = data[columnFirstName]
      ..lastName = data[columnLastName];
  }

  @override
  Future<Map<String, Object>> convertToMap(User entity) async {
    return {
      columnId: entity.id,
      columnEmail: entity.email,
      columnFirstName: entity.firstName,
      columnLastName: entity.lastName,
    };
  }
}
