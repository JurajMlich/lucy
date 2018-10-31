import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deposit.g.dart';

@JsonSerializable()
class Deposit extends IdAware<String> {
  String id;
  Set<String> ownersIds;
  Set<String> accessibleByUsersIds;
  String name;
  double balance;
  bool disabled;
  DepositType type;

  Deposit(this.id);

  factory Deposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);

  Map<String, dynamic> toJson() => _$DepositToJson(this);

  @override
  String toString() {
    return 'Deposit{id: $id, ownersIds: $ownersIds, accessibleByUsersIds: $accessibleByUsersIds, name: $name, balance: $balance, disabled: $disabled, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deposit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum DepositType {
  @JsonValue('CASH')
  cash,
@JsonValue('BANK_ACCOUNT')
  bankAccount,
}
