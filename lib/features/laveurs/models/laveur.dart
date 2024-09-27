import 'package:cloud_firestore/cloud_firestore.dart';

class Laveur {
  final String id;
  final String nom;
  final String contact;
  final bool actif;
  final String accountId;
  final DateTime dateCreated;

  const Laveur(
      {required this.id,
      required this.nom,
      required this.contact,
      required this.actif,
      required this.accountId,
      required this.dateCreated});

  factory Laveur.fromFirestore(QueryDocumentSnapshot map) {
    return Laveur(
        id: map.id,
        accountId: map['accountId'],
        actif: map['actif'],
        contact: map['contact'],
        nom: map['nom'],
        dateCreated: map['dateCreated'].toDate());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'contact': contact,
      'accountId': accountId,
      'actif': actif,
      'dateCreated': dateCreated
    };
  }
}
