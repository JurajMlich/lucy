String underscoreToCamelCase(String value) {
  if (value == null) {
    return value;
  }

  StringBuffer buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    var char = value[i];

    if (char == '_' && value.length > i + 1) {
      buffer.write(value[i + 1]);
      i++;
    } else {
      buffer.write(char.toLowerCase());
    }
  }

  return buffer.toString();
}

String camelCaseToUnderscore(String value) {
  if (value == null) {
    return value;
  }

  StringBuffer buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    var char = value[i];

    if (char.toUpperCase() == char) {
      buffer.write('_');
    }

    buffer.write(char);
  }

  return buffer.toString().toUpperCase();
}
