int dateTimeToInt(DateTime value) {
  if (value == null) {
    return null;
  }

  return value.toUtc().millisecondsSinceEpoch;
}

DateTime intToDateTime(int value) {
  if(value == null) {
    return null;
  }

  return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
}
