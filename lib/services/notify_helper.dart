import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '/models/birthday.dart';
import '/ui/pages/notification_screen.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer' as developer;

import 'app_notif_channels.dart';

class NotifyHelper {
  static final _instance = NotifyHelper._internal();
  factory NotifyHelper() => _instance;
  NotifyHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String selectedNotificationPayload = '';

  int notifCount = 0;

  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  late NotificationDetails notificationDetails;

  Future<void> init() async {
    tz.initializeTimeZones();
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
    // await requestIOSPermissions(flutterLocalNotificationsPlugin);

    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        appNotificationsConfig.channelId,
        appNotificationsConfig.channelTitle,
        channelDescription: appNotificationsConfig.channelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
          InitializationSettings(
            iOS: DarwinInitializationSettings(
              requestSoundPermission: false,
              requestBadgePermission: false,
              requestAlertPermission: false,
              onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            ),
            android: const AndroidInitializationSettings('appicon'),
          ),
          onDidReceiveBackgroundNotificationResponse:
              _handleReceivingNotifications);
      developer.log('INITIALIZED', name: 'NOTIFICATION');
    } catch (err) {
      developer.log(err.toString(), name: 'NOTIFICATION');
    }
  }

  void _handleReceivingNotifications(NotificationResponse payload) async {
    selectNotificationSubject.add(payload.toString());
  }

  displayNotification({required String title, required String body}) async {
    await incrementNotifBadgeCount();

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  cancelNotification(Birthday bd) async {
    await decrementNotifBadgeCount();
    await flutterLocalNotificationsPlugin.cancel(bd.id!);
    developer.log('Notification is canceled', name: 'NOTIFICATION');
  }

  cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    developer.log('Notification is canceled', name: 'NOTIFICATION');
  }

  scheduledNotification(int hour, int minutes, Birthday bd) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      bd.id!,
      bd.title,
      bd.note,
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTenAM(
        hour,
        minutes,
        bd.remind!,
        bd.repeat!,
        bd.date!,
      ),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${bd.title} | ${bd.note} | ${bd.startTime}|',
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(
      int hour, int minutes, int remind, String repeat, String date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    var formattedDate = DateFormat.yMd().parse(date);

    final tz.TZDateTime fd = tz.TZDateTime.from(formattedDate, tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, fd.year, fd.month, fd.day, hour, minutes);

    scheduledDate = afterRemind(remind, scheduledDate);

    if (scheduledDate.isBefore(now)) {
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 1, hour, minutes);
      }
      if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 7, hour, minutes);
      }
      if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year,
            (formattedDate.month) + 1, formattedDate.day, hour, minutes);
      }
      scheduledDate = afterRemind(remind, scheduledDate);
    }

    developer.log('Next scheduledDate = $scheduledDate');

    return scheduledDate;
  }

  tz.TZDateTime afterRemind(int remind, tz.TZDateTime scheduledDate) {
    if (remind == 5) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
    }
    if (remind == 10) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
    }
    if (remind == 15) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
    }
    if (remind == 20) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
    }
    return scheduledDate;
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> incrementNotifBadgeCount() async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(notifCount++);
    }
  }

  Future<void> decrementNotifBadgeCount() async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(notifCount--);
    }
  }

  Future<void> clearNotifBadgeCount() async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      notifCount = 0;
      FlutterAppBadger.updateBadgeCount(notifCount);
    }
  }

//Older IOS
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    /* showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Title'),
        content: const Text('Body'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
    );
 */
    Get.dialog(Text(body!));
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      developer.log('My payload is $payload', name: 'NOTIFICATION');
      await Get.to(() => NotificationScreen(payload: payload));
    });
  }
}
