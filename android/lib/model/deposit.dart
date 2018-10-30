import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deposit.g.dart';

@JsonSerializable()
class Deposit extends IdAware<String> {
  String id;
  Set<String> ownersIds;
  String name;
  double balance;

  Deposit(this.id);

  factory Deposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);

  Map<String, dynamic> toJson() => _$DepositToJson(this);

  @override
  String toString() {
    return 'Deposit{id: $id, ownersId: $ownersIds, name: $name, balance: '
        '$balance}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deposit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
