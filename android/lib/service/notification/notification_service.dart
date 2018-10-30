import 'dart:async';
import 'dart:ui';

import 'package:android/service/notification/notification_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for showing notifications
class NotificationService {
  static const notificationIdSyncExecuting = 0;
  static const notificationIdSyncError = 1;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService() {
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Show or update notification with the given id.
  Future<void> showNotification(
    NotificationChannel channel,
    int id,
    String title,
    String body, {
    Importance importance = Importance.Default,
    Priority priority = Priority.Default,
    bool playSound = true,
    bool vibrate = true,
    Color color,
    int progress,
    int maxProgress,
    bool ongoing,
  }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channel.id, channel.name, channel.description,
        importance: importance,
        priority: priority,
        ongoing: ongoing,
        color: color,
        progress: progress,
        maxProgress: maxProgress,
        showProgress: progress != null && maxProgress != null,
        playSound: playSound,
        enableVibration: vibrate);

    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: playSound);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics);
  }

  /// Hide notification with the given id.
  Future<void> hideNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
