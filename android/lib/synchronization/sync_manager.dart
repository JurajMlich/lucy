import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/exception/server_unavailable_exception.dart';
import 'package:android/exception/unauthorized_exception.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/service/notification/notification_channel.dart';
import 'package:android/service/notification/notification_service.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/synchronization.dart';
import 'package:android/ui/flushbar_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class managing synchronization. Prevents two synchronizations happening
/// at the same time. Performs incremental sync when possible. Shows proper
/// notifications.
class SyncManager {
  final List<SyncService> _services;
  final ResolvedInstructionRepository _resolvedInstanceInstructionRepository;
  final SharedPreferences _sharedPreferences;
  final NotificationService _notificationService;

  bool _executing = false;
  int _attempt = 0;

  SyncManager(
    this._sharedPreferences,
    this._notificationService,
    this._resolvedInstanceInstructionRepository,
    this._services,
  );

  /// Perform incremental sync if possible. Otherwise, perform full sync. If
  /// already performing, throws IllegalStateException.
  Future<Null> synchronize({bool forceFullSync = false}) async {
    if (_executing) {
      throw IllegalStateException('Already executing');
    }
    _executing = true;
    _attempt++;

    if (forceFullSync) {
      await _sharedPreferences.setBool('fullSyncCompleted', false);
    }

    var doIncrementalSync =
        _sharedPreferences.getBool('fullSyncCompleted') ?? false;

    try {
      _notificationService
          .hideNotification(NotificationService.notificationIdSyncError);
      _notificationService.showNotification(
        NotificationChannel.CHANNEL_SYNC,
        NotificationService.notificationIdSyncExecuting,
        'Synchronization',
        'Synchronization in progress.',
        ongoing: true,
        playSound: false,
        vibrate: false,
      );
      await Synchronization(
        _sharedPreferences,
        _resolvedInstanceInstructionRepository,
        _services,
      ).execute(doIncrementalSync);
    } on UnauthorizedException {
      // try to synchronize one more time
      if (_attempt > 2) {
        if (!doIncrementalSync) {
          await _sharedPreferences.setBool('fullSyncCompleted', false);
        }
        _notificationService.showNotification(
          NotificationChannel.CHANNEL_SYNC_ERRORS,
          NotificationService.notificationIdSyncError,
          'Could not synchronize',
          'Cannot authenticate',
          priority: Priority.High,
          importance: Importance.Max,
        );
        return;
      }

      _executing = false;
      await synchronize();
      return;
    } on ServerUnavailableException {
      if (!doIncrementalSync) {
        await _sharedPreferences.setBool('fullSyncCompleted', false);
      }
      _notificationService.showNotification(
        NotificationChannel.CHANNEL_SYNC_ERRORS,
        NotificationService.notificationIdSyncError,
        'Could not synchronize',
        'Server unavailable',
        priority: Priority.High,
        importance: Importance.Max,
      );
      return;
    } finally {
      _executing = false;
      _notificationService
          .hideNotification(NotificationService.notificationIdSyncExecuting);
    }

    await _sharedPreferences.setBool('fullSyncCompleted', true);
    _executing = false;
    _attempt = 0;
  }
}
