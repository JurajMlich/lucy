import 'package:meta/meta.dart';

@immutable
class FinancesState {
  FinancesState();

  factory FinancesState.initial() {
    return FinancesState();
  }

  FinancesState copyWith() {
    return FinancesState();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FinancesState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
