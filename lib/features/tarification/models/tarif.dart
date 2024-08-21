import 'package:autoclean/features/tarification/models/option_tarif.dart';

class Tarif {
  final String libelle;
  final List<OptionTarif> options;

  const Tarif({required this.libelle, required this.options});

  factory Tarif.fromJson(Map<String, dynamic> json) => Tarif(
      libelle: json['libelle'],
      options: List<OptionTarif>.from(
          json['options'].map((e) => OptionTarif.fromJson(e))));
}
