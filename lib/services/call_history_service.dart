import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_call/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/call_history_model.dart';

class CallHistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------
  // SAVE CALL HISTORY USING CALL ID
  // --------------------------------------------------

  Future<void> saveCallHistory({
    required String callID,
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required String callType,
    required String status,
    required int duration,
  }) async {
    final call = CallHistoryModel(
      id: callID,
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      callType: callType,
      status: status,
      timestamp: DateTime.now(),
      duration: duration,
    );

    await _firestore
        .collection('callHistory')
        .doc(callID)
        .set(
          call.toMap(),
          SetOptions(merge: true),
        );

    print(
      'CALL HISTORY: Saved call $callID',
    );
  }

  // --------------------------------------------------
  // GET CURRENT USER'S CALL HISTORY
  // --------------------------------------------------

Future<UserModel?> getUserById(
  String userId,
) async {
  final doc = await _firestore
      .collection('users')
      .doc(userId)
      .get();

  if (!doc.exists || doc.data() == null) {
    return null;
  }

  return UserModel.fromMap(
    doc.data()!,
  );
}
  Future<List<CallHistoryModel>> getCallHistory() async {
  final user = _auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    final callerSnapshot = await _firestore
        .collection('callHistory')
        .where('callerId', isEqualTo: user.uid)
        .get();

    final receiverSnapshot = await _firestore
        .collection('callHistory')
        .where('receiverId', isEqualTo: user.uid)
        .get();

    final Map<String, CallHistoryModel> historyMap = {};

    for (final doc in callerSnapshot.docs) {
      final call = CallHistoryModel.fromMap(doc.data());
      historyMap[call.id] = call;
    }

    for (final doc in receiverSnapshot.docs) {
      final call = CallHistoryModel.fromMap(doc.data());
      historyMap[call.id] = call;
    }

    final history = historyMap.values.toList();

    history.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return history;
  } catch (e) {
    print('CALL HISTORY SERVICE ERROR: $e');
    rethrow;
  }
}}