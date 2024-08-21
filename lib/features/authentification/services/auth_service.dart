import 'package:autoclean/core/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signinWithEmailAndPassword(
      {required String email, required String password}) async {
    String message = '';
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      var user = credential.user;
      if (user != null) {
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        message = 'Verifiez e-mail ou mot de passe';
      } else {
        message = e.code;
      }
      showToast(message: message);
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
      showToast(message: message);
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
