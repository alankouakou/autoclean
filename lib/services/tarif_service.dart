import 'dart:core';

import 'package:autoclean/models/tarifs.dart';
import 'package:flutter/services.dart';

class TarifService {
  List<Tarif> tarifs = [];

  Future<List<Tarif>> getTarifs() async {
    var jsonString = await rootBundle.loadString('assets/tarifs.json');

    tarifs = tarifFromJson(jsonString);

    return tarifs;
  }

  Future<Tarif> getTarif(String nom) async {
    var jsonString = await rootBundle.loadString('assets/tarifs.json');

    tarifs = tarifFromJson(jsonString);

    return tarifs.firstWhere(
        (t) => t.libelle.toLowerCase().contains(nom.toLowerCase()),
        orElse: () => Tarif(
            libelle: 'Default',
            options: List<Option>.from([
              Option(libelle: 'Lavage simple', prix: 1000),
              Option(libelle: 'Lavage + Aspirateur', prix: 1500),
            ])));

    //Tarif(libelle: 'Default', options: List<Option>.from([Option(libelle: 'Basic', prix: 1000)]));
  }

  List<Option> getOptions(String tarif) {
    return tarifs
        .where((t) => t.libelle.toLowerCase().contains(tarif.toLowerCase()))
        .first
        .options;
  }
}
