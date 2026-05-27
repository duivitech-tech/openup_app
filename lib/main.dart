// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_routes.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar icons on iOS — handled by theme on Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F10),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const OpenUpApp());
}

class OpenUpApp extends StatelessWidget {
  const OpenUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // Inject core services at startup
      initialBinding: InitialBinding(),

      // Initial route
      initialRoute: AppRoutes.splash,

      // All routes with bindings
      getPages: AppPages.pages,

      // Default page transition
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),

      // Locale
      locale: const Locale('en', 'IN'),
    );
  }
}
