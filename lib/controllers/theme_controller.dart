import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default to system preference
    isDarkMode.value =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setDark() {
    isDarkMode.value = true;
    Get.changeThemeMode(ThemeMode.dark);
  }

  void setLight() {
    isDarkMode.value = false;
    Get.changeThemeMode(ThemeMode.light);
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
