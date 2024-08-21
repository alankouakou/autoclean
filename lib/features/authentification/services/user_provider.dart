import 'package:autoclean/features/authentification/models/compte.dart';
import 'package:autoclean/features/authentification/models/role.dart';
import 'package:autoclean/features/authentification/models/statut_compte.dart';
import 'package:autoclean/features/authentification/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNotifierProvider =
    NotifierProvider<UserNotifier, User>(() => UserNotifier());

class UserNotifier extends Notifier<User> {
  @override
  build() {
    return User(
        name: 'Alan',
        username: 'test',
        password: 'test',
        role: const Role(id: 1, libelle: 'Admin'),
        compte: Compte(id: 1, name: 'default', statut: StatutCompte.actif),
        statut: StatutUser.nouveau,
        dateMaj: DateTime.now());
  }

  void update({String? name, String? username}) {
    state = state.copyWith(name: name, username: username);
  }
}
