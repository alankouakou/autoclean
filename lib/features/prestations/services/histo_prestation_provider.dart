import 'dart:async';

import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';
import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:autoclean/features/prestations/services/histo_mvt_caisse_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cette classe est utilisée à des fins de démo
/// pour charger des données tests générées à la volée
///
/// A terme, les données proviendront d'un backend via une API

final histoPrestationsProvider =
    AsyncNotifierProvider<HistoPrestationsNotifier, List<Prestation>>(
        HistoPrestationsNotifier.new);

class HistoPrestationsNotifier extends AsyncNotifier<List<Prestation>> {
  final firestore = FirestoreService();
  final List<Prestation> _prestations = [];

  @override
  FutureOr<List<Prestation>> build() async {
    final caisseId = ref.watch(histoCaisseIdProvider);
    return getFromFirestore(caisseId: caisseId);
  }

  void add(Prestation p) async {
    firestore.addPrestation(p);
    print('prestation ${p.libelle} ajoutée');

    final accountId = ref.read(authProvider).currentUser?.uid;

    final dataFromFirestore = await firestore.dataFromFirestore();

    var temp = dataFromFirestore.docs
        .map((item) => Prestation.fromFirestore(item))
        .where((p) => p.accountId == accountId)
        .toList();
  }

  Future<List<Prestation>> getByCaisseId(String id) async {
    return getFromFirestore(caisseId: id);
  }

  Future<List<Prestation>> getFromFirestore({String? caisseId}) async {
    final accountId = ref.watch(authProvider).currentUser?.uid ?? '';

    final dataFromFirestore = await firestore.dataFromFirestore();

    var temp = dataFromFirestore.docs
        .map((item) => Prestation.fromFirestore(item))
        .where((p) => p.accountId == accountId)
        .toList();

    if (caisseId != null && caisseId.isNotEmpty) {
      temp = temp.where((p) => p.caisseId == caisseId).toList();
    }

    return temp;
  }
}
