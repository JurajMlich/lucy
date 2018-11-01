import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deposit.g.dart';

@JsonSerializable()
class FinanceDeposit extends IdAware<String> {
  String id;
  Set<String> ownersIds;
  Set<String> accessibleByUsersIds;
  String name;
  double balance;
  bool disabled;
  FinanceDepositType type;

  FinanceDeposit(this.id);

  factory FinanceDeposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);

  Map<String, dynamic> toJson() => _$DepositToJson(this);

  @override
  String toString() {
    return 'FinanceDeposit{id: $id, ownersIds: $ownersIds, accessibleByUsersIds:'
        ' $accessibleByUsersIds, name: $name, balance: $balance, disabled: '
        '$disabled, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceDeposit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum FinanceDepositType {
  @JsonValue('CASH')
  cash,
  @JsonValue('BANK_ACCOUNT')
  bankAccount,
}
