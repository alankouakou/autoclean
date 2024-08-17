import 'package:autoclean/models/statut_compte.dart';
import 'package:autoclean/models/user.dart';

class Compte {
  final int id;
  final String name;
  final StatutCompte statut;
  List<User>? users;
  String? email;
  String? telephone;
  DateTime? dateMaj;

  Compte({
    required this.id,
    required this.name,
    required this.statut,
  }) {
    email = '';
    telephone = '';
    dateMaj = null;
    users = [];
  }
}
