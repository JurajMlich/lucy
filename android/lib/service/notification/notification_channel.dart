/// Notification channel (allowing user to block one channel of notifications.)
class NotificationChannel {
  static const CHANNEL_SYNC = NotificationChannel(
    "Synchronization",
    "Synchronization",
    "Data synchronization with server",
  );
  static const CHANNEL_SYNC_ERRORS = NotificationChannel(
    "Synchronization errors",
    "Synchronization errors",
    "Data synchronization errors with server",
  );

  final String id;
  final String name;
  final String description;

  const NotificationChannel(this.id, this.name, this.description);
}
