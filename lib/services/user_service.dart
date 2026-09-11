import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<List<UserModel>> getUsers() async {
    final currentUser = _auth.currentUser;

    print('USER SERVICE: Current UID = ${currentUser?.uid}');

    final snapshot =
        await _firestore.collection('users').get();

    print(
      'USER SERVICE: Firestore documents = ${snapshot.docs.length}',
    );

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != currentUser?.uid)
        .toList();
  }
}