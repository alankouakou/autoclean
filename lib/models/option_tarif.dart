class OptionTarif {
  final String libelle;
  final double prix;

  const OptionTarif({required this.libelle, required this.prix});

  factory OptionTarif.fromJson(Map<String, dynamic> json) =>
      OptionTarif(libelle: json['libelle'], prix: double.parse(json['prix']));
}
