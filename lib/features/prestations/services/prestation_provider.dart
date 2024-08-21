import 'dart:convert';

import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cette classe est utilisée à des fins de démo
/// pour charger des données tests générées à la volée
///
/// A terme, les données proviendront d'un backend via une API

final df = DateFormat('d/M/y HH:mm:ss');

final restoreData = StateProvider<bool>((ref) => false);

final prestationsNotifierProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

class PrestationsNotifier extends Notifier<List<Prestation>> {
  final prestations = <Prestation>[];
  @override
  List<Prestation> build() {
    final bool restore = ref.watch(restoreData);
    print('Inside prestationProvider. Valeur de restore: $restore');

    if (restore) initPrestations();
    return prestations;
  }

  void add(Prestation p) {
    state = [p, ...state];
    print('prestation ${p.libelle} ajoutée');
  }

  void clear() {
    state.clear();
  }

  int count() {
    return state.length;
  }

  double totalCA() {
    return state.fold(
        0.0, (acc, e) => acc + e.prix); // Somme des prestations à l'instant T
  }

  void save() async {
    var sp = await SharedPreferences.getInstance();
    var jsonString = jsonEncode(state.map((p) => p.toJson()).toList());

    sp.setString('historique', jsonString);

    //print(jsonString);
  }

  void initPrestations() async {
    var sp = await SharedPreferences.getInstance();
    var rawData = sp.getString('historique') ?? '{}';

    print('init: $rawData');

    var jsonData = jsonDecode(rawData);
    if (jsonData.length > 0) {
      prestations.addAll(List<Prestation>.from(
          jsonData.map((element) => Prestation.fromJson(element))));
    }
  }
}
