import 'package:android/redux/app/app_action.dart';
import 'package:android/redux/app/app_state.dart';
import 'package:android/redux/dasboard/dashboard_reducer.dart';
import 'package:android/redux/finances/finances_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  var synchronizing = state.synchronizing;

  if (action is AppSynchronizeAction) {
    synchronizing = true;
  } else if (action is AppSynchronizedAction) {
    synchronizing = false;
  }

  return state.copyWith(
    synchronizing: synchronizing,
    financesState: financesReducer(state.financesState, action),
    dashboardState: dashboardReducer(state.dashboardState, action),
  );
}
