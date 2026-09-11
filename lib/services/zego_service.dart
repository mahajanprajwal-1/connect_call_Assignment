import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'call_history_service.dart';

class ZegoService {
  static const int appID = 1725200913;

  // Keep your real AppSign locally.
  // DO NOT commit the real AppSign to GitHub.
  static const String appSign = '7ffe6db1486f677c0488e4fe0be727bcceb2a0f1d7d0b9c5f97783c64df93260';

  static bool isInitialized = false;

  static String? activeCallID;
  static String? activeCallerId;
  static String? activeCallerName;
  static String? activeReceiverId;
  static String? activeReceiverName;
  static String? activeCallType;

  static DateTime? callStartedAt;

  static final CallHistoryService _historyService =
      CallHistoryService();

  static Future<void> initialize({
    required String userID,
    required String userName,
  }) async {
    try {
      if (isInitialized) {
        print('ZEGO: Already initialized');
        return;
      }

      print('ZEGO: Initializing...');
      print('ZEGO USER ID: $userID');
      print('ZEGO USER NAME: $userName');

      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: userID,
        userName: userName,
        plugins: [
          ZegoUIKitSignalingPlugin(),
        ],

        invitationEvents:
            ZegoUIKitPrebuiltCallInvitationEvents(
          onIncomingCallReceived: (
            String callID,
            ZegoCallUser caller,
            ZegoCallInvitationType callType,
            List<ZegoCallUser> callees,
            String customData,
          ) {
            print('ZEGO: Incoming call received');
            print('Call ID: $callID');
            print('Caller: ${caller.name}');
            print('Caller UID: ${caller.id}');

            final currentUser =
                FirebaseAuth.instance.currentUser;

            activeCallID = callID;
            activeCallerId = caller.id;
            activeCallerName = caller.name;
            activeReceiverId = currentUser?.uid;
            activeReceiverName =
                currentUser?.displayName ??
                    currentUser?.email ??
                    'User';

            activeCallType =
                callType ==
                        ZegoCallInvitationType.videoCall
                    ? 'video'
                    : 'audio';

            callStartedAt = null;
          },

          onIncomingCallCanceled: (
            String callID,
            ZegoCallUser caller,
            String customData,
          ) {
            print('ZEGO: Incoming call canceled');

            if (activeCallID == callID) {
              _saveCall(
                status: 'cancelled',
                duration: 0,
              );

              clearActiveCall();
            }
          },

          onIncomingCallTimeout: (
            String callID,
            ZegoCallUser caller,
          ) {
            print('ZEGO: Incoming call timeout');

            if (activeCallID == callID) {
              _saveCall(
                status: 'missed',
                duration: 0,
              );

              clearActiveCall();
            }
          },

          onIncomingCallDeclineButtonPressed: () {
            print('ZEGO: Incoming call declined');

            if (activeCallID != null) {
              _saveCall(
                status: 'rejected',
                duration: 0,
              );

              clearActiveCall();
            }
          },

          onIncomingCallAcceptButtonPressed: () {
            print('ZEGO: Incoming call accepted');

            callStartedAt = DateTime.now();
          },

          onOutgoingCallSent: (
            String callID,
            ZegoCallUser caller,
            ZegoCallInvitationType callType,
            List<ZegoCallUser> callees,
            String customData,
          ) {
            print('ZEGO: Outgoing call sent');
            print('Call ID: $callID');
          },

          onOutgoingCallAccepted: (
            String callID,
            ZegoCallUser callee,
          ) {
            print('ZEGO: Outgoing call accepted');
            print('Callee: ${callee.name}');

            callStartedAt = DateTime.now();
          },

          onOutgoingCallRejectedCauseBusy: (
            String callID,
            ZegoCallUser callee,
            String customData,
          ) {
            print('ZEGO: Callee is busy');

            _saveCall(
              status: 'rejected',
              duration: 0,
            );

            clearActiveCall();
          },

          onOutgoingCallDeclined: (
            String callID,
            ZegoCallUser callee,
            String customData,
          ) {
            print('ZEGO: Outgoing call declined');

            _saveCall(
              status: 'rejected',
              duration: 0,
            );

            clearActiveCall();
          },

          onOutgoingCallTimeout: (
            String callID,
            List<ZegoCallUser> callees,
            bool isVideoCall,
          ) {
            print('ZEGO: Outgoing call timeout');

            _saveCall(
              status: 'missed',
              duration: 0,
            );

            clearActiveCall();
          },

          onOutgoingCallCancelButtonPressed: () {
            print('ZEGO: Outgoing call canceled');

            if (activeCallID != null) {
              _saveCall(
                status: 'cancelled',
                duration: 0,
              );

              clearActiveCall();
            }
          },
        ),

        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (
            ZegoCallEndEvent event,
            VoidCallback defaultAction,
          ) {
            print('ZEGO: Call ended');
            print('Call ID: ${event.callID}');
            print('End reason: ${event.reason}');

            final duration = callStartedAt == null
                ? 0
                : DateTime.now()
                    .difference(callStartedAt!)
                    .inSeconds;

            _saveCall(
              status: 'completed',
              duration: duration,
            );

            clearActiveCall();

            defaultAction();
          },
        ),
      );

      isInitialized = true;

      print('ZEGO: Initialization successful');
      print('ZEGO: Signaling plugin attached');
    } catch (e, stackTrace) {
      print('ZEGO INITIALIZATION ERROR: $e');
      print('ZEGO STACK TRACE: $stackTrace');

      isInitialized = false;

      rethrow;
    }
  }

  static void startOutgoingCall({
    required String callID,
    required String receiverUserId,
    required String receiverUserName,
    required bool isVideoCall,
  }) {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    activeCallID = callID;

    activeCallerId = currentUser?.uid;
    activeCallerName =
        currentUser?.displayName ??
            currentUser?.email ??
            'User';

    activeReceiverId = receiverUserId;
    activeReceiverName = receiverUserName;

    activeCallType =
        isVideoCall ? 'video' : 'audio';

    callStartedAt = null;

    print('ZEGO: Active outgoing call stored');
  }

  static Future<void> _saveCall({
    required String status,
    required int duration,
  }) async {
    if (activeCallID == null ||
        activeCallerId == null ||
        activeReceiverId == null) {
      print('CALL HISTORY: Missing call information');
      return;
    }

    try {
      await _historyService.saveCallHistory(
        callID: activeCallID!,
        callerId: activeCallerId!,
        callerName: activeCallerName ?? 'User',
        receiverId: activeReceiverId!,
        receiverName:
            activeReceiverName ?? 'User',
        callType: activeCallType ?? 'audio',
        status: status,
        duration: duration,
      );

      print(
        'CALL HISTORY: Saved $status '
        '($duration seconds)',
      );
    } catch (e) {
      print('CALL HISTORY SAVE ERROR: $e');
    }
  }

  static void clearActiveCall() {
    activeCallID = null;
    activeCallerId = null;
    activeCallerName = null;
    activeReceiverId = null;
    activeReceiverName = null;
    activeCallType = null;
    callStartedAt = null;

    print('ZEGO: Active call cleared');
  }

  static Future<void> dispose() async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService()
          .uninit();

      isInitialized = false;
      clearActiveCall();

      print('ZEGO: Service uninitialized');
    } catch (e) {
      print('ZEGO DISPOSE ERROR: $e');
    }
  }
}