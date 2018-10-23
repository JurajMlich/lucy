class InstanceInstructionDto {
  int id;
  String data;
  DateTime creationDatetime;
}

enum InstanceInstructionType {
  REFRESH_DATA,
  DELETE_DATA
}
