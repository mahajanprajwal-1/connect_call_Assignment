import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ConnectCallApp());
}

class ConnectCallApp extends StatelessWidget {
  const ConnectCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConnectCall',

      initialRoute: AppRoutes.splash,

      getPages: AppPages.routes,
    );
  }
}