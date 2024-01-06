import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifConfig {
  final String channelId;
  final String channelTitle;
  final Importance notifImportance;
  final Priority notifPriority;
  final String? channelDesc;
  final String? notifTicker;

  const AppNotifConfig({
    required this.channelId,
    required this.channelTitle,
    required this.notifImportance,
    required this.notifPriority,
    this.channelDesc,
    this.notifTicker,
  });
}

const appNotificationsConfig = AppNotifConfig(
  channelId: 'reminders',
  channelTitle: 'Birthday Reminders',
  channelDesc: "Don't forget your important birthdays.",
  notifImportance: Importance.max,
  notifPriority: Priority.high,
  notifTicker: 'ticker',
);
