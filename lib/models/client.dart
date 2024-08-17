class Client {
  final int id;
  final String nom;
  final int credits;

  const Client({required this.id, required this.nom, required this.credits});

  Client.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        nom = json['nom'],
        credits = int.parse(json['credits']);

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'credits': credits};
}
