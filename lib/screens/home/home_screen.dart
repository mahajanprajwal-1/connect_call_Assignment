import 'package:connect_call/core/theme/app_theme.dart';
import 'package:connect_call/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final currentUser = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // Logo + title
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ConnectCall',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Profile
          _AppBarAction(
            icon: Icons.person_outline_rounded,
            tooltip: 'My Profile',
            onTap: () => Get.toNamed(AppRoutes.profile),
            isDark: isDark,
          ),
          // Call History
          _AppBarAction(
            icon: Icons.history_rounded,
            tooltip: 'Call History',
            onTap: () => Get.toNamed(AppRoutes.history),
            isDark: isDark,
          ),
          // Logout
          _AppBarAction(
            icon: Icons.logout_rounded,
            tooltip: 'Logout',
            onTap: () async {
              try {
                await authService.logout();
                Get.offAllNamed(AppRoutes.login);
              } catch (e) {
                Get.snackbar(
                  'Logout Error',
                  'Unable to logout. Please try again.',
                );
              }
            },
            isDark: isDark,
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: controller.searchUsers,
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
            ),
          ),

          // ── Logged-in chip ───────────────────────────────────────────────
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          currentUser.email ?? '',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // ── Section label ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'People',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                // Refresh
                GestureDetector(
                  onTap: controller.loadUsers,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Users list ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 2.5,
                  ),
                );
              }

              // Empty state
              if (controller.filteredUsers.isEmpty) {
                return _buildEmptyState(context, colorScheme, textTheme);
              }

              // Users
              return RefreshIndicator(
                color: colorScheme.primary,
                onRefresh: controller.loadUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return _UserCard(
                      user: user,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No users found',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AppBar icon button ─────────────────────────────────────────────────────────
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _AppBarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: IconButton(
        icon: Icon(icon, size: 22),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _UserCard({
    required this.user,
    required this.isDark,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final String initial =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.toNamed(
              AppRoutes.userProfile,
              arguments: user,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primaryDark,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Online indicator
                    if (user.isOnline)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.online,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Name + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty ? user.name : 'Unknown User',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: user.isOnline
                                  ? AppColors.online
                                  : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user.isOnline ? 'Online' : 'Offline',
                            style: textTheme.bodySmall?.copyWith(
                              color: user.isOnline
                                  ? AppColors.online
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
