import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

class FinanceTransaction extends IdAware<String> {
  String id;
  String sourceDepositId;
  String targetDepositId;
  FinanceTransactionState state;
  double value;
  DateTime executionDatetime;
  String creatorId;
  String name;
  String note;
  Set<String> categoriesIds;

  FinanceTransaction(this.id);

  @override
  String toString() {
    return 'FinanceTransaction{id: $id, sourceDepositId: $sourceDepositId, '
        'targetDepositId: $targetDepositId, state: $state, value: $value,'
        ' executionDatetime: $executionDatetime, creatorId: $creatorId, name: '
        '$name, note: $note, categoriesIds: $categoriesIds}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum FinanceTransactionState {
  @JsonValue('PLANNED')
  planned,
  @JsonValue('BLOCKED')
  blocked,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXECUTED')
  executed
}
