class OptionTarif {
  final String libelle;
  final double prix;
  final bool fixedPrice;

  const OptionTarif(
      {required this.libelle, required this.prix, required this.fixedPrice});

  factory OptionTarif.fromJson(Map<String, dynamic> json) => OptionTarif(
      libelle: json['libelle'],
      prix: double.parse(json['prix']),
      fixedPrice: json['fixedPrice'] ?? true);
}
