// To parse this JSON data, do
//
//     final tarif = tarifFromJson(jsonString);

import 'dart:convert';

List<Tarif> tarifFromJson(String str) =>
    List<Tarif>.from(json.decode(str).map((x) => Tarif.fromJson(x)));

String tarifToJson(List<Tarif> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Tarif {
  final String libelle;
  final List<Option> options;

  Tarif({
    required this.libelle,
    required this.options,
  });

  factory Tarif.fromJson(Map<String, dynamic> json) => Tarif(
        libelle: json["libelle"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "libelle": libelle,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}

class Option {
  final String libelle;
  final double prix;

  Option({
    required this.libelle,
    required this.prix,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        libelle: json["libelle"],
        prix: json["prix"],
      );

  Map<String, dynamic> toJson() => {
        "libelle": libelle,
        "prix": prix,
      };
}
