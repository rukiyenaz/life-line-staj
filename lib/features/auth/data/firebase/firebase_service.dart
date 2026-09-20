import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_line/features/auth/domain/entities/user_model.dart';
import 'package:life_line/features/auth/domain/repositories/auth_repo.dart';

class FirebaseService implements AuthRepository {


  FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
  
  @override
  Future<DoctorUser?> getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return user != null ? DoctorUser.fromJson({
      'id': user.uid,
      'email': user.email ?? '',
      'ad': user.displayName ?? '',
    }) : null;
  }

  Future<DoctorUser?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('doctorUsers').doc(userId).get();
      if (doc.exists) {
        return DoctorUser.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
    }
  }


  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }


  @override
  Future<DoctorUser?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      DoctorUser newUser = DoctorUser.fromJson({
        'id': userCredential.user?.uid,
        'email': email,
        'ad': userCredential.user?.displayName ?? '',
      });

      return newUser;
    } catch (e) {
      return null;
    }
  }

  
  @override
  Future<DoctorUser?> saveFirebaseUser(DoctorUser user) async {
    try {
      await FirebaseFirestore.instance.collection('doctorUsers').doc(user.id).set({
        'ad': user.ad,
        'email': user.email,
      });
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}