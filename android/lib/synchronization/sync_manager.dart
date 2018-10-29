import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/synchronization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class managing synchronization. Prevents two synchronizations happening
/// at the same time. Performs incremental sync when possible.
class SyncManager {
  final List<SyncService> _services;
  final ResolvedInstructionRepository _resolvedInstanceInstructionRepository;
  final SharedPreferences _sharedPreferences;

  bool _executing = false;

  SyncManager(
    this._sharedPreferences,
    this._resolvedInstanceInstructionRepository,
    this._services,
  );

  /// Perform incremental sync if possible. Otherwise, perform full sync. If
  /// already performing, throws IllegalStateException.
  Future<Null> synchronize() async {
    if (_executing) {
      throw IllegalStateException('Already executing');
    }
    _executing = true;

    var doIncrementalSync =
        _sharedPreferences.getBool('fullSyncCompleted') ?? false;

    try {
      await Synchronization(
        _sharedPreferences,
        _resolvedInstanceInstructionRepository,
        _services,
      ).execute(doIncrementalSync);
    } catch(e) {
      if(!doIncrementalSync){
        await _sharedPreferences.setBool('fullSyncCompleted', false);
      }
      _executing = false;
      rethrow;
    }

    await _sharedPreferences.setBool('fullSyncCompleted', true);
    _executing = false;
  }
}

