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
      : id = int.parse(json['id']),
        libelle = json['libelle'],
        prix = json['prix'],
        montantRecu = json['montantRecu'],
        monnaie = json['monnaie'],
        annulee = json['annulee'],
        datePrestation = json['datePrestation'],
        detailsVehicule = json['detailsVehicule'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'prix': prix,
        'montantRecu': montantRecu,
        'monnaie': monnaie,
        'annulee': annulee,
        'datePrestation': datePrestation,
        'detailsVehicule': detailsVehicule
      };
}
