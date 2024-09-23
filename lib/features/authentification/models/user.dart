import 'package:equatable/equatable.dart';
import 'account.dart';

class User extends Equatable {
  final String username;
  final String email;
  final String password;
  final String role;
  final Account account;
  final StatutUser statut;
  final DateTime dateExpiration;
  final DateTime dateMaj;

  const User(
      {required this.username,
      required this.email,
      required this.password,
      required this.role,
      required this.account,
      required this.statut,
      required this.dateExpiration,
      required this.dateMaj});

  User copyWith(
      {String? username,
      String? email,
      String? password,
      String? role,
      Account? account,
      StatutUser? statut,
      DateTime? dateExpiration,
      DateTime? dateMaj}) {
    return User(
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        account: account ?? this.account,
        statut: statut ?? this.statut,
        dateExpiration: dateExpiration ?? this.dateExpiration,
        dateMaj: dateMaj ?? this.dateMaj);
  }

  @override
  List<Object?> get props => [email, password];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'account': account,
      'statut': statut,
      'dateExpiration': dateExpiration
    };
  }
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
