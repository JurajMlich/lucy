import 'package:meta/meta.dart';

@immutable
class DashboardState {
  final bool initialized;
  final double todaySpent;
  final double todayMax;
  final double balance;

  DashboardState({
    @required this.initialized,
    @required this.todaySpent,
    @required this.todayMax,
    @required this.balance,
  });

  factory DashboardState.initial() {
    return DashboardState(
      initialized: false,
      todayMax: null,
      todaySpent: null,
      balance: null,
    );
  }

  DashboardState copyWith({
    bool initialized,
    double todaySpent,
    double todayMax,
    double balance,
  }) {
    return DashboardState(
      initialized: initialized,
      todayMax: todayMax,
      todaySpent: todaySpent,
      balance: balance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardState &&
          runtimeType == other.runtimeType &&
          initialized == other.initialized &&
          todaySpent == other.todaySpent &&
          todayMax == other.todayMax &&
          balance == other.balance;

  @override
  int get hashCode =>
      initialized.hashCode ^
      todaySpent.hashCode ^
      todayMax.hashCode ^
      balance.hashCode;
}
