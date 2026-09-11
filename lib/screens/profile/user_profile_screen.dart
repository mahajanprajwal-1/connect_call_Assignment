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
    if (arguments == null ||
        arguments is! UserModel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 70,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                'User information is unavailable.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please go back and select a user again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // At this point it is definitely a UserModel.
    final UserModel user = arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                user.name.isNotEmpty
                    ? user.name
                    : 'Unknown User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _startCall(
                      user: user,
                      isVideoCall: false,
                    );
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Audio Call'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _startCall(
                      user: user,
                      isVideoCall: true,
                    );
                  },
                  icon: const Icon(
                    Icons.videocam,
                  ),
                  label: const Text('Video Call'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}