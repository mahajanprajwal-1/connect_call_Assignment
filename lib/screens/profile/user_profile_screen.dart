import 'package:connect_call/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../models/user_model.dart';
import '../../services/zego_service.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _startCall({
    required UserModel user,
    required bool isVideoCall,
  }) async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You are not logged in.',
      );
      return;
    }

    // Keep call ID short for ZEGOCLOUD.
    final callID =
        'c${DateTime.now().millisecondsSinceEpoch}';

    try {
      print('--------------------------------');
      print('ZEGO CALL START');
      print('Target UID: ${user.uid}');
      print('Target Name: ${user.name}');
      print('Video: $isVideoCall');
      print('Call ID: $callID');

      ZegoService.startOutgoingCall(
        callID: callID,
        receiverUserId: user.uid,
        receiverUserName: user.name,
        isVideoCall: isVideoCall,
      );

      final result =
          await ZegoUIKitPrebuiltCallInvitationService()
              .send(
        invitees: [
          ZegoCallUser(
            user.uid,
            user.name,
          ),
        ],
        isVideoCall: isVideoCall,
        callID: callID,
        resourceID: 'connectcall_call',
      );

      print('ZEGO SEND RESULT: $result');

      if (!result) {
        ZegoService.clearActiveCall();

        Get.snackbar(
          'Call Failed',
          'Unable to send call invitation.',
        );
      } else {
        print(
          'ZEGO: Invitation sent successfully',
        );
      }

      print('--------------------------------');
    } catch (e, stackTrace) {
      ZegoService.clearActiveCall();

      print('ZEGO CALL ERROR: $e');
      print('STACK TRACE: $stackTrace');

      Get.snackbar(
        'Call Failed',
        'Unable to start the call.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic arguments = Get.arguments;

    // No arguments or wrong argument type.
    if (arguments == null || arguments is! UserModel) {
      return _buildErrorState(context);
    }

    final UserModel user = arguments;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String initial =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero section ───────────────────────────────────────────────
            Container(
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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  // Avatar with online indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
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
                      // Online badge
                      if (user.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.online,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    user.name.isNotEmpty ? user.name : 'Unknown User',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // Email
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 14),

                  // Online/Offline status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.isOnline
                          ? AppColors.online.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: user.isOnline
                            ? AppColors.online.withValues(alpha: 0.3)
                            : colorScheme.outline.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 6),
                        Text(
                          user.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: user.isOnline
                                ? AppColors.online
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Call actions ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Start a call',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Audio Call button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _startCall(
                        user: user,
                        isVideoCall: false,
                      ),
                      icon: const Icon(
                        Icons.call_rounded,
                        size: 20,
                      ),
                      label: const Text('Audio Call'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Video Call button
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _startCall(
                        user: user,
                        isVideoCall: true,
                      ),
                      icon: const Icon(
                        Icons.videocam_rounded,
                        size: 20,
                      ),
                      label: const Text('Video Call'),
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

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_rounded,
                  size: 40,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'User not found',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'User information is unavailable.\nPlease go back and select a user again.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
