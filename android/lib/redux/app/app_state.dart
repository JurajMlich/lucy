import 'package:android/redux/dasboard/dashboard_state.dart';
import 'package:android/redux/finances/finances_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final FinancesState financesState;
  final DashboardState dashboardState;
  final bool initialized;
  final bool synchronizing;

  AppState({
    @required this.initialized,
    @required this.synchronizing,
    @required this.financesState,
    @required this.dashboardState,
  });

  factory AppState.initial() {
    return AppState(
      initialized: false,
      synchronizing: false,
      financesState: FinancesState.initial(),
      dashboardState: DashboardState.initial(),
    );
  }

  AppState copyWith({
    bool initialized,
    bool synchronizing,
    FinancesState financesState,
    DashboardState dashboardState,
  }) {
    return AppState(
        initialized: initialized,
        synchronizing: synchronizing,
        financesState: financesState,
        dashboardState: dashboardState);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          financesState == other.financesState &&
          dashboardState == other.dashboardState &&
          initialized == other.initialized &&
          synchronizing == other.synchronizing;

  @override
  int get hashCode =>
      financesState.hashCode ^
      dashboardState.hashCode ^
      initialized.hashCode ^
      synchronizing.hashCode;
}
