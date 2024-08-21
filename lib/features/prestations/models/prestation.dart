import 'package:intl/intl.dart';

final df = DateFormat('dd/MM/yyyy HH:mm:ss');

class Prestation {
  final int id;
  final String libelle;
  final double prix;
  final double montantRecu;
  final double monnaie;
  final bool annulee;
  final DateTime datePrestation;
  final String detailsVehicule; // indique si la prestation est annulée

  const Prestation({
    required this.id,
    required this.libelle,
    required this.prix,
    required this.montantRecu,
    required this.monnaie,
    required this.annulee,
    required this.datePrestation,
    required this.detailsVehicule,
  });

  Prestation.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        libelle = json['libelle'],
        prix = json['prix'] as double,
        montantRecu = json['montantRecu'] as double,
        monnaie = json['monnaie'] as double,
        annulee = json['annulee'],
        datePrestation = df.parse(json['datePrestation']),
        detailsVehicule = json['detailsVehicule'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'prix': prix,
        'montantRecu': montantRecu,
        'monnaie': monnaie,
        'annulee': annulee,
        'datePrestation': df.format(datePrestation),
        'detailsVehicule': detailsVehicule
      };
}
