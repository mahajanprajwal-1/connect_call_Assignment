import 'package:connect_call/routes/bindings/home_binding.dart';
import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/history/call_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import 'bindings/auth_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),

    GetPage(
  name: AppRoutes.login,
  page: () => const LoginScreen(),
  binding: AuthBinding(),
),

    GetPage(
  name: AppRoutes.register,
  page: () => const RegisterScreen(),
  binding: AuthBinding(),
),

    GetPage(
  name: AppRoutes.home,
  page: () => const HomeScreen(),
  binding: HomeBinding(),
),

    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileScreen(),
    ),

    GetPage(
      name: AppRoutes.history,
      page: () => const CallHistoryScreen(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
  ];
}