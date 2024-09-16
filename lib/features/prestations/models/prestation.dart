import 'package:autoclean/core/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Prestation {
  final int id;
  final String libelle;
  final double prix;
  final double montantRecu;
  final double monnaie;
  final bool annulee;
  final DateTime datePrestation;
  final String detailsVehicule;
  final String? caisseId;
  final String accountId; // indique si la prestation est annulée

  const Prestation(
      {required this.id,
      required this.libelle,
      required this.prix,
      required this.montantRecu,
      required this.monnaie,
      required this.annulee,
      required this.datePrestation,
      required this.detailsVehicule,
      this.caisseId,
      required this.accountId});

  Prestation.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        libelle = json['libelle'],
        prix = json['prix'] as double,
        montantRecu = json['montantRecu'] as double,
        monnaie = json['monnaie'] as double,
        annulee = json['annulee'],
        datePrestation = Utils.dateFull.parse(json['datePrestation']),
        detailsVehicule = json['detailsVehicule'],
        caisseId = json['caisseId'],
        accountId = json['accountId'];

  factory Prestation.fromFirestore(QueryDocumentSnapshot document) {
    //print(document['datePrestation']);

    return Prestation(
        id: document['id'],
        libelle: document['libelle'],
        prix: document['prix'] as double,
        montantRecu: document['montantRecu'] as double,
        monnaie: document['monnaie'] as double,
        annulee: document['annulee'],
        datePrestation: Utils.dateFull.parse(document['datePrestation']),
        detailsVehicule: document['detailsVehicule'],
        caisseId: document['caisseId'],
        accountId: document['accountId']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'prix': prix,
        'montantRecu': montantRecu,
        'monnaie': monnaie,
        'annulee': annulee,
        'datePrestation': Utils.dateFull.format(datePrestation),
        'detailsVehicule': detailsVehicule,
        'caisseId': caisseId,
        'accountId': accountId
      };
}
