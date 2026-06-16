import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

class EVotingApp extends StatelessWidget {
  const EVotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'E-Voting System',
          debugShowCheckedModeBanner: false,

          // Themes
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,

          // Routing
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,

          // Default transitions
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),

          // Locale
          locale: const Locale('en', 'US'),

          // Snackbar position
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
        ));
  }
}
