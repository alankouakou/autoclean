import 'package:autoclean/features/authentification/models/compte.dart';
import 'package:autoclean/features/authentification/models/statut_compte.dart';

class MouvementCompte {
  const MouvementCompte(
      {required this.id,
      required this.compte,
      required this.statut,
      required this.dateMaj});

  final int id;
  final Compte compte;
  final StatutCompte statut;
  final DateTime dateMaj;
}
