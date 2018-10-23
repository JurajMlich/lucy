import 'package:android/model/user.dart';
import 'package:android/redux/app/app_action.dart';
import 'package:android/redux/app/app_state.dart';
import 'package:android/redux/dasboard/dashboard_action.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/sync_manager.dart';
import 'package:redux/redux.dart';
import 'package:sqflite/sqflite.dart';

class DashboardMiddleware extends MiddlewareClass<AppState> {
  final UserRepository _userRepository;
  final SyncManager _syncManager;

  DashboardMiddleware(Database database, this._syncManager)
      : _userRepository = UserRepository(database);

  @override
  Future<Null> call(Store store, action, NextDispatcher next) async {
    next(action);

    if (action is AppSynchronizeAction) {
      await _syncManager.synchronize();
      next(AppSynchronizedAction());
    }

    var list = await _userRepository.findAll();

    if (action is DashboardInitializeAction) {
      next(DashboardInitializedAction(25, 100, 12444));
    }
  }
}
