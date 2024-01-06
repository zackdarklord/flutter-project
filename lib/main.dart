import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:workmanager/workmanager.dart';
import 'dart:developer' as developer;
import 'db/db_helper.dart';
import 'models/birthday.dart';
import 'services/notify_helper.dart';
import 'services/theme_services.dart';
import 'ui/pages/home_page.dart';

@pragma('vm:entry-point')
void reminderEntryPoint() {
  Workmanager().executeTask(
    (task, inputData) async {
      try {
        switch (task) {
          case 'reminder':
            {
              await checkForReminders();
              break;
            }
          default:
            break;
        }
        return Future.value(true);
      } on Exception catch (err) {
        developer.log(
          err.toString(),
          name: 'WORK_MANAGER',
          level: 2,
        );

        return Future.error(err);
      }
    },
  );
}

Future<void> checkForReminders() async {
  await NotifyHelper().init();
  await DBHelper.initDb();
  NotifyHelper().requestIOSPermissions();

  (await DBHelper.query())
      .map((data) => Birthday.fromJson(data))
      .toList()
      .where(
        (t) =>
            !DateTime.parse(t.date!).isBefore(DateTime.now()) &&
            !DateTime.parse(t.date!).isAfter(DateTime.now()),
      )
      .forEach((element) => NotifyHelper()
          .displayNotification(title: element.title!, body: element.note!));
}

//future
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  await NotifyHelper().init();
  await Workmanager().initialize(reminderEntryPoint);
  NotifyHelper().requestIOSPermissions();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Workmanager().cancelByTag('reminder');
        break;

      // case AppLifecycleState.inactive:
      //   print("INACTIVE");

      //   break;

      case AppLifecycleState.paused:
        Workmanager().registerPeriodicTask(
          'reminderId',
          'appReminder',
          tag: 'reminder',
          backoffPolicy: BackoffPolicy.linear,
          frequency: const Duration(minutes: 45),
          initialDelay: const Duration(hours: 1),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(networkType: NetworkType.connected),
        );

        break;

      // case AppLifecycleState.detached:
      //   print("DETACHED");

      //   break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeServices().theme,
      title: 'Birthday Reminder',
      debugShowCheckedModeBanner: false,
      home: const /* AuthScreen(),*/ HomePage(),
    );
  }
}
