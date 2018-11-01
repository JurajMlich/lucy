import 'package:intl/intl.dart';

class Config {
  static final serverUrl = 'http://192.168.43.167:8080';
  static final dateTimeFormat = DateFormat('d.M.y HH:mm');
  static final dateFormat = DateFormat('d.M.y');
  static final timeFormat = DateFormat('HH:mm');
  static final currencyDetailedFormat = NumberFormat.currency(symbol: '€',
      decimalDigits: 2);
  static final currencyFormat = NumberFormat.currency(symbol: '€',
      decimalDigits: 0);
}
