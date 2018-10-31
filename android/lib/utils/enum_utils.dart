String enumToString(value) {
  if (value == null) {
    return null;
  }
  var raw = value.toString();
  return raw.substring(raw.indexOf('.') + 1);
}

T stringToEnum<T>(List<dynamic> enumValues, String value) {
  if (value == null) {
    return null;
  }
  var base = enumValues[0].toString();
  base = base.substring(0, base.indexOf('.'));
  return enumValues.firstWhere((v) => v.toString() == '$base.$value',
      orElse: null);
}
