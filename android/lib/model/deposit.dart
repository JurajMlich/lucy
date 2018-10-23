import 'package:android/model/id_aware.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deposit.g.dart';

@JsonSerializable()
class Deposit extends IdAware<int> {
  int id;
  int userId;
  String name;
  double balance;

  Deposit();

  factory Deposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);
  Map<String, dynamic> toJson() => _$DepositToJson(this);
}