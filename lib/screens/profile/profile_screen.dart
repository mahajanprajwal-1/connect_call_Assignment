import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_call/controllers/theme_controller.dart';
import 'package:connect_call/core/theme/app_theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2.5,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Profile hero ───────────────────────────────────────────
                  _buildProfileHero(context, isDark, colorScheme, textTheme),

                  // ── Content ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        // Dark mode card
                        Obx(
                          () => _buildSettingCard(
                            context: context,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            icon: themeController.isDarkMode.value
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            iconColor: themeController.isDarkMode.value
                                ? const Color(0xFF6B6FD6)
                                : const Color(0xFFF59E0B),
                            title: 'Dark Mode',
                            subtitle: themeController.isDarkMode.value
                                ? 'Dark theme is active'
                                : 'Light theme is active',
                            trailing: Switch(
                              value: themeController.isDarkMode.value,
                              onChanged: (_) =>
                                  themeController.toggleTheme(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Name card
                        _buildInfoCard(
                          context: context,
                          isDark: isDark,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: name.isNotEmpty ? name : 'Not available',
                        ),

                        const SizedBox(height: 8),

                        // Email card
                        _buildInfoCard(
                          context: context,
                          isDark: isDark,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: email.isNotEmpty ? email : 'Not available',
                        ),

                        const SizedBox(height: 28),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHero(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final String initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [AppColors.lightBackground, AppColors.lightSurface],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            name.isNotEmpty ? name : 'User',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            email,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // "My Account" pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Verified Account',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required bool isDark,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
