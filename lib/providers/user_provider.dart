// Mock class to manage Users login
// Until the API is built

import 'package:autoclean/features/authentification/models/compte.dart';
import 'package:autoclean/features/authentification/models/role.dart';
import 'package:autoclean/features/authentification/models/statut_compte.dart';
import 'package:autoclean/features/authentification/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final users = [];

class UserNotifier extends Notifier<List<User>> {
  @override
  List<User> build() {
    return [
      User(
          username: 'admin',
          password: 'admin',
          name: 'Admin',
          compte: Compte(
            id: 1,
            name: 'default',
            statut: StatutCompte.actif,
          ),
          role: const Role(id: 1, libelle: 'Admin'),
          statut: StatutUser.actif,
          dateMaj: DateTime.now()),
      User(
          username: 'test',
          password: 'test',
          name: 'Test',
          compte: Compte(
            id: 1,
            name: 'default',
            statut: StatutCompte.actif,
          ),
          role: const Role(id: 2, libelle: 'User'),
          statut: StatutUser.actif,
          dateMaj: DateTime.now()),
    ];
  }

  void add(User u) {
    state = [...state, u];
  }

  void remove(User u) {
    state = state.where((elt) => elt.username != u.username).toList();
  }

  int totalUsers() {
    return state.length;
  }
}
