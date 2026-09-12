import 'package:connect_call/controllers/theme_controller.dart';
import 'package:connect_call/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register ThemeController BEFORE the app starts
  Get.put(
    ThemeController(),
    permanent: true,
  );

  // Give ZEGOCLOUD access to the app Navigator
  ZegoUIKitPrebuiltCallInvitationService()
      .setNavigatorKey(navigatorKey);

  // Enable ZEGOCLOUD system calling UI
  await ZegoUIKitPrebuiltCallInvitationService()
      .useSystemCallingUI([
    ZegoUIKitSignalingPlugin(),
  ]);

  runApp(const ConnectCallApp());
}

class ConnectCallApp extends StatelessWidget {
  const ConnectCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      title: 'ConnectCall',

      // Premium purple Material 3 light theme
      theme: AppTheme.lightTheme,

      // Premium purple Material 3 dark theme
      darkTheme: AppTheme.darkTheme,

      // Initial theme — respects ThemeController
      themeMode: ThemeMode.system,

      initialRoute: AppRoutes.splash,

      getPages: AppPages.routes,
    );
  }
}