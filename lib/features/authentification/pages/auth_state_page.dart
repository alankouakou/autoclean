import 'package:autoclean/features/authentification/pages/login_new.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';
import 'package:autoclean/main_page.dart';
import 'package:flutter/material.dart';

class AuthStatePage extends StatelessWidget {
  AuthStatePage({super.key});
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final firebaseAuthId = snapshot.data!.uid;
            return MainPage(firebaseAuthId: firebaseAuthId);
          } else {
            return const LoginNew();
          }
        });
  }
}
