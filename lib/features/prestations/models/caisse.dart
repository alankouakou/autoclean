class Caisse {
  final int id;
  final String libelle;
  String caissier;
  DateTime? dateOuverture;
  DateTime? dateFermeture;
  double soldeCaisse;
  String? accountId;

  Caisse({
    required this.id,
    required this.libelle,
    required this.soldeCaisse,
    required this.caissier,
  }) : dateOuverture = DateTime.now();
}
