import 'package:autoclean/features/authentification/pages/login.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';

import 'package:autoclean/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStatePage extends ConsumerWidget {
  const AuthStatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return StreamBuilder(
        stream: auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (auth.currentUser == null) {
              return const Login();
            }
            return const MainPage();
          } else {
            return const Login();
          }
        });
  }
}
