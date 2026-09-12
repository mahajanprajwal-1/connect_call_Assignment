import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_call/controllers/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../services/zego_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeController =
      Get.find<ThemeController>();

  final AuthService _authService = AuthService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;

  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? user.email ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          name = user.displayName ?? '';
          email = user.email ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('PROFILE ERROR: $e');

      setState(() {
        name = user.displayName ?? '';
        email = user.email ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    try {
      await ZegoService.dispose();

      // Updates Firestore isOnline = false
      await _authService.logout();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Unable to logout.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  CircleAvatar(
                    radius: 55,
                    child: Text(
                      name.isNotEmpty
                          ? name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    name.isNotEmpty
                        ? name
                        : 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // DARK MODE
                  Obx(
                    () => Card(
                      child: SwitchListTile(
                        secondary: Icon(
                          themeController.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        title: const Text(
                          'Dark Mode',
                        ),
                        subtitle: Text(
                          themeController.isDarkMode.value
                              ? 'Dark theme enabled'
                              : 'Light theme enabled',
                        ),
                        value: themeController.isDarkMode.value,
                        onChanged: (_) {
                          themeController.toggleTheme();
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                      ),
                      title: const Text(
                        'Name',
                      ),
                      subtitle: Text(
                        name.isNotEmpty
                            ? name
                            : 'Not available',
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.email,
                      ),
                      title: const Text(
                        'Email',
                      ),
                      subtitle: Text(email),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: logout,
                      icon: const Icon(
                        Icons.logout,
                      ),
                      label: const Text(
                        'Logout',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}