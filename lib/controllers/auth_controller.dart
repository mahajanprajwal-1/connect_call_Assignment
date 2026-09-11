import 'package:connect_call/services/zego_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email and password',
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = await _authService.login(
        email: email,
        password: password,
      );

     if (user != null) {
  print('LOGIN: Firebase login successful');
  print('LOGIN UID: ${user.uid}');

  try {
    await ZegoService.initialize(
      userID: user.uid,
      userName: user.email ?? 'User',
    );

    print('ZEGO: Initialization successful');
  } catch (e) {
    print('ZEGO ERROR: $e');
  }

  Get.snackbar(
    'Success',
    'Login successful',
  );

  Get.offAllNamed('/home');
}

    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login Failed',
        _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (name.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    Get.snackbar(
      'Error',
      'Please fill all fields',
    );
    return;
  }

  if (password != confirmPassword) {
    Get.snackbar(
      'Error',
      'Passwords do not match',
    );
    return;
  }

  if (password.length < 6) {
    Get.snackbar(
      'Error',
      'Password must contain at least 6 characters',
    );
    return;
  }

  try {
    isLoading.value = true;

    // 1. Create Firebase Authentication account
    final user = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (user != null) {
  await ZegoService.initialize(
    userID: user.uid,
    userName: name,
  );

  print('AUTH: User created = ${user.uid}');
  print('ZEGOCLOUD: Initialized');

  Get.snackbar(
    'Success',
    'Account created successfully',
  );

  Get.offAllNamed('/home');
}
  } on FirebaseAuthException catch (e) {
    print('Firebase Auth Error Code: ${e.code}');
    print('Firebase Auth Error Message: ${e.message}');

    Get.snackbar(
      'Registration Failed',
      '${e.code}: ${e.message}',
    );
  } on FirebaseException catch (e) {
    print('Firestore Error Code: ${e.code}');
    print('Firestore Error Message: ${e.message}');

    Get.snackbar(
      'Database Error',
      '${e.code}: ${e.message}',
    );
  } catch (e) {
    print('Registration Error: $e');

    Get.snackbar(
      'Error',
      'Something went wrong. Please try again.',
    );
  } finally {
    isLoading.value = false;
  }
}

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}