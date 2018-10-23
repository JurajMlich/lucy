import 'package:android/redux/app/app_state.dart';
import 'package:android/redux/app/app_reducer.dart';
import 'package:android/redux/dasboard/dashboard_middleware.dart';
import 'package:android/synchronization/sync_manager.dart';
import 'package:redux/redux.dart';
import 'package:sqflite/sqflite.dart';

Future<Store<AppState>> createStore(Database database, SyncManager syncManager) async {
  return Store(
    appReducer,
    initialState: AppState.initial(),
    distinct: true,
    middleware: [
      DashboardMiddleware(database, syncManager)
    ],
  );
}