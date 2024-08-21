class Caisse {
  final int id;
  final String libelle;
  String caissier;
  DateTime? dateOuverture;
  DateTime? dateFermeture;
  double soldeCaisse;

  Caisse(
      {required this.id,
      required this.libelle,
      required this.soldeCaisse,
      required this.caissier});
}
