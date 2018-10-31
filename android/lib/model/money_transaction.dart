import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

class MoneyTransaction extends IdAware<String> {
  String id;
  String sourceDepositId;
  String targetDepositId;
  TransactionState state;
  double value;
  DateTime executionDatetime;
  String creatorId;
  String name;
  String note;
  Set<String> categoriesIds;

  MoneyTransaction(this.id);

  @override
  String toString() {
    return 'Transaction{id: $id, sourceDepositId: $sourceDepositId, targetDepositId: $targetDepositId, state: $state, value: $value, executionDatetime: $executionDatetime, creatorId: $creatorId, name: $name, note: $note, categoriesIds: $categoriesIds}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneyTransaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum TransactionState {
  @JsonValue('PLANNED')
  planned,
  @JsonValue('BLOCKED')
  blocked,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXECUTED')
  executed
}
