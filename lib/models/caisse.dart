class Caisse {
  final int id;
  final String libelle;
  final DateTime dateOuverture;
  final DateTime dateFermeture;
  final double soldeCaisse;
  final String caissier;

  Caisse(
      {required this.id,
      required this.libelle,
      required this.dateOuverture,
      required this.dateFermeture,
      required this.soldeCaisse,
      required this.caissier});
}
