import 'package:cloud_firestore/cloud_firestore.dart';

class MouvementCaisse {
  final String typeMouvement;
  final String details;
  final double montant;
  final String caisseId;
  final DateTime dateMaj;

  const MouvementCaisse(
      {required this.typeMouvement,
      required this.details,
      required this.montant,
      required this.caisseId,
      required this.dateMaj});

  factory MouvementCaisse.fromFirestore({required DocumentSnapshot docu}) {
    return MouvementCaisse(
        typeMouvement: docu['typeMouvement'],
        details: docu['details'],
        montant: docu['montant'].toDouble(),
        caisseId: docu['caisseId'],
        dateMaj: (docu['dateMaj'] as Timestamp).toDate());
  }

  factory MouvementCaisse.fromJson({required json}) {
    return MouvementCaisse(
        typeMouvement: json['typeMouvement'],
        caisseId: json['caisseId'],
        details: json['details'],
        montant: json['montant'],
        dateMaj: (json['dateMaj'] as Timestamp).toDate());
  }
  Map<String, dynamic> toJson() => {
        'typeMouvement': typeMouvement,
        'caisseId': caisseId,
        'details': details,
        'montant': montant,
        'dateMaj': dateMaj
      };
}
