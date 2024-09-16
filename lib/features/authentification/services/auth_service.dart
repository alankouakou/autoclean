import 'package:autoclean/core/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String get userId => _firebaseAuth.currentUser!.uid;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signinWithEmailAndPassword(
      {required String email, required String password}) async {
    String message = '';
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final sp = await SharedPreferences.getInstance();
      var user = credential.user;

      if (user != null) {
        sp.setString('firebase_auth_uid',
            user.uid); //stocke dans SharedPreferences le user UID
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        message = 'Verifiez e-mail ou mot de passe';
      } else if (e.code == 'user-disabled') {
        message = 'Votre compte est Inactif';
      } else {
        message = e.code;
      }
      Utils.showToast(message: message, color: Colors.red.shade300);
    }

    return null;
  }

  Future<User?> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    String message = '';
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      var user = credential.user;
      if (user != null) {
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        message = 'Verifiez e-mail ou mot de passe';
      } else if (e.code == 'weak-password') {
        message = 'mot de passe faible';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ce compte existe déjà!';
      } else if (e.code == 'invalid-email') {
        message = 'E-mail invalide!';
      } else {
        message = e.code;
      }
      Utils.showErrorMessage(message: message);
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    //Utils.showSuccessMessage(message: 'Utilisateur déconnecté!');
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      Utils.showSuccessMessage(message: e.code);
    }
  }
}
