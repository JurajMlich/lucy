import 'package:android/model/deposit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deposit_operations.g.dart';

@JsonSerializable()
class DepositCreateOperation {
  static const String identifier = 'DEPOSIT_CREATE_OPERATION';

  Deposit deposit;

  DepositCreateOperation(this.deposit);

  factory DepositCreateOperation.fromJson(Map<String, dynamic> json) =>
      _$DepositCreateOperationFromJson(json);

  Map<String, dynamic> toJson() => _$DepositCreateOperationToJson(this);
}

@JsonSerializable()
class DepositUpdateOperation {
  static const String identifier = 'DEPOSIT_UPDATE_OPERATION';

  Deposit deposit;

  DepositUpdateOperation(this.deposit);

  factory DepositUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$DepositUpdateOperationFromJson(json);

  Map<String, dynamic> toJson() => _$DepositUpdateOperationToJson(this);
}
