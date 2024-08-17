class TypePrestation {
  final int id;
  final String libelle;
  final double prix;

  TypePrestation({required this.id, required this.libelle, required this.prix});

  TypePrestation.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        libelle = json['libelle'] ?? '',
        prix = json['prix'];

  Map<String, dynamic> toJson() => {'id': id, 'libelle': libelle};
}
