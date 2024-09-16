import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class TarifService {
  List<Tarif> tarifs = [];

  Future<List<Tarif>> getListeTarifs(String? userUID) async {
// si tarif inexistant, charger tarif par defaut (assets/tarifs.json)
    final remoteTarif = await getRemoteTarif(userUID);
    final localTarif = await rootBundle.loadString('assets/tarifs.json');
    print('Remote tarif: $remoteTarif');
    //var jsonString = remoteTarif.isNotEmpty ? remoteTarif : localTarif;
    var jsonString = localTarif;

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

  Future<String> getRemoteTarif(String? userUID) async {
    String result = '';
    String filedir = userUID ?? 'tarifs';
    try {
      final fileRef =
          FirebaseStorage.instance.ref().child(filedir).child('tarifs.json');

      result = await fileRef.getDownloadURL();
      print('Firebase storage: Download Url ---> $result');

      final rawJson = await fileRef.getData();
      result = rawJson != null ? utf8.decode(rawJson) : '';
    } catch (err) {
      err.toString();
    }
    return result;
  }
}
