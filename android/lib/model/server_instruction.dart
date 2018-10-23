import 'package:android/model/id_aware.dart';

class ServerInstruction extends IdAware<int> {
  int id;
  String type;
  String data;
  DateTime dateTime;

  @override
  String toString() {
    return 'SyncChange{id: $id, type: $type, dateTime: $dateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerInstruction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          id != null;

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;
}
