import 'package:android/model/id_aware.dart';

class User extends IdAware<String> {
  String id;
  String email;
  String firstName;
  String lastName;

  User(this.id);

  @override
  String toString() {
    return 'User{id: $id, email: $email, firstName: $firstName, lastName: $lastName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          id != null;

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;
}
