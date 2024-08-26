import 'dart:convert';

import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cette classe est utilisée à des fins de démo
/// pour charger des données tests générées à la volée
///
/// A terme, les données proviendront d'un backend via une API

final df = DateFormat('d/M/y HH:mm:ss');

final restoreData = StateProvider<bool>((ref) => false);

final prestationsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final fireStoreProvider = ref.watch(firestoreProvider);

  return fireStoreProvider.getPrestations();
});

final prestationsNotifierProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

class PrestationsNotifier extends Notifier<List<Prestation>> {
  final firestore = FirestoreService();
  final List<Prestation> _prestations = [];

  @override
  List<Prestation> build() {
    getFromFirestore();

    return _prestations;
  }

  void add(Prestation p) async {
    firestore.addPrestation(p);
    print('prestation ${p.libelle} ajoutée');

    final sp = await SharedPreferences.getInstance();
    final accountId = sp.getString('firebase_auth_uid');

    final dataFromFirestore = await firestore.dataFromFirestore();

    var temp = dataFromFirestore.docs
        .map((item) => Prestation.fromFirestore(item))
        .where((p) => p.accountId == accountId)
        .toList();
/*     _prestations.clear();
    _prestations.addAll(temp);
 */
    state = [...temp];
  }

  List<Prestation> get prestations => _prestations;

  void getFromFirestore() async {
    final sp = await SharedPreferences.getInstance();
    final accountId = sp.getString('firebase_auth_uid');

    final dataFromFirestore = await firestore.dataFromFirestore();

    var temp = dataFromFirestore.docs
        .map((item) => Prestation.fromFirestore(item))
        .where((p) => p.accountId == accountId)
        .toList();
    _prestations.clear();

    _prestations.addAll(temp);

    //state = [...temp];
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
  }

  void initPrestations() async {}
}
