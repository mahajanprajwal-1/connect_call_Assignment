import 'dart:async';

import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() {
    Timer(
      const Duration(seconds: 2),
      () {
        Get.offNamed('/login');
      },
    );
  }
}