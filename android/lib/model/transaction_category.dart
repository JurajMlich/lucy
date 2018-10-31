import 'package:android/model/id_aware.dart';

class TransactionCategory extends IdAware<String> {
  String id;
  String name;
  String color;
  bool negative;
  bool disabled;

  TransactionCategory(this.id);

  @override
  String toString() {
    return 'Transaction{id: $id, name: $name, color: $color, negative: $negative, disabled: $disabled}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
