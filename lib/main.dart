import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/utils/connectivity_service.dart';
import 'controllers/theme_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize GetStorage
  await GetStorage.init();

  // Register global services
  Get.put(ConnectivityService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const EVotingApp());
}
