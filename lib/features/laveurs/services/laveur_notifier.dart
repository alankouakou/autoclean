import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentification/services/auth_service.dart';
import '../models/laveur.dart';

final selectedLaveur = StateProvider<String>((ref) => '');

final laveurProvider =
    AsyncNotifierProvider<LaveurNotifier, List<Laveur>>(LaveurNotifier.new);

class LaveurNotifier extends AsyncNotifier<List<Laveur>> {
  LaveurNotifier();

  CollectionReference laveursCollection =
      FirebaseFirestore.instance.collection("laveurs");

  @override
  FutureOr<List<Laveur>> build() async {
    final auth = ref.watch(authProvider);
    final accountId = auth.currentUser!.uid;
    return getLaveurs(accountId);
  }

  Future<void> add(Laveur laveur) async {
    await laveursCollection.add(laveur.toJson());
  }

  Future<void> delete(String id) async {
    await laveursCollection.doc(id).delete();
  }

  Future<void> maj(String id, Laveur laveur) async {
    await laveursCollection
        .doc(id)
        .update({'nom': laveur.nom, 'contact': laveur.contact});
  }

  Future<List<Laveur>> getLaveurs(String accountId) async {
    QuerySnapshot results = await laveursCollection
        .where('accountId', isEqualTo: accountId)
        .orderBy('dateCreated', descending: true)
        .get();

    final listLaveurs =
        results.docs.map((obj) => Laveur.fromFirestore(obj)).toList();

    return listLaveurs;
  }

  Future<String> getNameById(String id) async {
    if (id.isNotEmpty) {
      final myDocument = await laveursCollection.doc(id).get();
      return myDocument['nom'];
    }
    return '';
  }
}
