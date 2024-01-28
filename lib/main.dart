import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'db/db_helper.dart';
import 'services/theme_services.dart';
import 'ui/pages/auth_screen.dart';
import 'ui/pages/home_page.dart';
import 'ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeServices().theme,
      title: 'Birthday Reminder',
      debugShowCheckedModeBanner: false,
      home:   DarkLightModeWrapper(),
    );
  }
}

class DarkLightModeWrapper extends StatelessWidget {
  final ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return ValueBuilder<ThemeMode?>(
      initialValue: _themeController.theme,
      builder: (themeMode, updateFn) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Birthday Reminder'),
            actions: [
              IconButton(
                icon: Icon(
                  _themeController.isDarkMode.value
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  _themeController.toggleTheme();
                },
              ),
            ],
          ),
          body: const HomePage(),
        );
      },
    );
  }
}

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    ThemeServices().setTheme(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}


class ThemeServices {
  ThemeMode theme = ThemeMode.light;

  void setTheme(ThemeMode selectedTheme) {
    theme = selectedTheme;
    Get.changeThemeMode(selectedTheme);
  }
}
