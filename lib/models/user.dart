import 'package:autoclean/models/compte.dart';
import 'package:autoclean/models/role.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final String name;
  final String password;
  final Role role;
  final Compte compte;
  final StatutUser statut;
  final DateTime dateMaj;

  const User(
      {required this.username,
      required this.name,
      required this.password,
      required this.role,
      required this.compte,
      required this.statut,
      required this.dateMaj});

  User copyWith(
      {String? username,
      String? name,
      String? password,
      Role? role,
      Compte? compte,
      StatutUser? statut,
      DateTime? dateMaj}) {
    return User(
        username: username ?? this.username,
        name: name ?? this.name,
        password: password ?? this.password,
        role: role ?? this.role,
        compte: compte ?? this.compte,
        statut: statut ?? this.statut,
        dateMaj: dateMaj ?? this.dateMaj);
  }

  @override
  List<Object?> get props => [username, password];
}

enum StatutUser {
  nouveau(value: 'Créé'),
  actif(value: 'Actif'),
  suspendu(value: 'Suspendu'),
  expire(value: 'Mot de passe expiré'),
  desactive(value: 'Désactivé');

  const StatutUser({required this.value});
  final String value;
}
