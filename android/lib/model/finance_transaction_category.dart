import 'package:android/model/id_aware.dart';

class FinanceTransactionCategory extends IdAware<String> {
  String id;
  String name;
  String color;
  bool negative;
  bool disabled;

  FinanceTransactionCategory(this.id);

  @override
  String toString() {
    return 'FinanceTransaction{id: $id, name: $name, color: $color, negative: '
        '$negative, disabled: $disabled}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceTransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
