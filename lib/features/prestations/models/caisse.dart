import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Caisse {
  String? id;
  String libelle;
  String caissier;
  DateTime? dateOuverture;
  DateTime? dateFermeture;
  double soldeInitial;
  double? recette;
  String? accountId;
  List<MouvementCaisse>? mouvements;

  Caisse(
      {required this.libelle,
      required this.caissier,
      this.id,
      this.dateOuverture,
      this.dateFermeture,
      required this.soldeInitial,
      this.recette,
      this.accountId,
      this.mouvements});

  factory Caisse.fromFirestore({required DocumentSnapshot map}) {
    print('inside fromFirestore: ${map['id']}');
    return Caisse(
      id: map.id,
      libelle: map['libelle'],
      caissier: map['caissier'],
      dateOuverture: map['dateOuverture'] != null
          ? (map['dateOuverture'] as Timestamp).toDate()
          : null,
      dateFermeture: map['dateFermeture'] != null
          ? (map['dateFermeture'] as Timestamp).toDate()
          : null,
      soldeInitial: map['soldeInitial'] as double,
      recette: map['recette'] as double,
      accountId: map['accountId'],
    );
  }

  Caisse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        libelle = json['libelle'],
        caissier = json['caissier'],
        dateOuverture = json['dateOuverture'].toDate(),
        dateFermeture = json['dateFermeture']?.toDate(),
        soldeInitial = json['soldeInitial'] ?? 0,
        recette = json['recette'] ?? 0,
        accountId = json['accountId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'caissier': caissier,
        'dateOuverture': dateOuverture,
        'dateFermeture': dateFermeture,
        'soldeInitial': soldeInitial,
        'recette': recette,
        'accountId': accountId
      };

  close(DateTime dateAlaFermeture) {
    dateFermeture = dateAlaFermeture;
  }

  Caisse copyWith(
      {libelle,
      caissier,
      id,
      dateOuverture,
      dateFermeture,
      soldeInitial,
      recette,
      accountId}) {
    return Caisse(
        id: id ?? this.id,
        libelle: libelle ?? this.libelle,
        caissier: caissier ?? this.caissier,
        dateOuverture: dateOuverture ?? this.dateOuverture,
        dateFermeture: dateFermeture ?? this.dateFermeture,
        soldeInitial: soldeInitial ?? this.soldeInitial,
        recette: recette ?? this.recette,
        accountId: accountId ?? this.accountId);
  }
}
