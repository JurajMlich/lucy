import 'package:android/redux/dasboard/dashboard_action.dart';
import 'package:android/redux/dasboard/dashboard_state.dart';

DashboardState dashboardReducer(DashboardState state, dynamic action) {
  if (action is DashboardInitializedAction) {
    print('initialized');
    return state.copyWith(
      initialized: true,
      todaySpent: action.todaySpent,
      todayMax: action.todayMax,
      balance: action.balance,
    );
  }

  if (action is DashboardDisposeAction) {
    print('dispose');
    return state.copyWith(
      initialized: false,
      todaySpent: null,
      todayMax: null,
      balance: null,
    );
  }

  return state;
}
