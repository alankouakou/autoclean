import 'package:autoclean/models/compte.dart';
import 'package:autoclean/models/role.dart';
import 'package:autoclean/models/statut_compte.dart';
import 'package:autoclean/models/user.dart';
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
