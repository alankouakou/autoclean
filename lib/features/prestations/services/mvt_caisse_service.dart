import 'dart:async';
import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mvtCaisseServiceProvider =
    Provider<MouvementCaisseService>((ref) => MouvementCaisseService());

final mvtCaisseNotifierProvider = AutoDisposeAsyncNotifierProvider<
    MouvementCaisseNotifier,
    List<MouvementCaisse>>(() => MouvementCaisseNotifier());

class MouvementCaisseNotifier
    extends AutoDisposeAsyncNotifier<List<MouvementCaisse>> {
  @override
  FutureOr<List<MouvementCaisse>> build() async {
    final idCaisse = ref.watch(caisseIdProvider);
    return fetchMvts(idCaisse);
  }

  Future<List<MouvementCaisse>> fetchMvts(String idCaisse) async {
    final mvtCaisseService = ref.watch(mvtCaisseServiceProvider);
    final results = await mvtCaisseService.fetchMvts(idCaisse);
    return results.docs
        .map((element) => MouvementCaisse.fromFirestore(docu: element))
        .toList();
  }

  Future<void> addMvt(MouvementCaisse mvtCaisse) async {
    final mvtCaisseService = ref.watch(mvtCaisseServiceProvider);
    mvtCaisseService.add(mvtCaisse);
  }

  Future<void> deleteMvtCaisse(String docId) async {
    final mvtCaisseService = ref.watch(mvtCaisseServiceProvider);
    mvtCaisseService.delete(docId);
  }

  Future<void> updateMvtCaisse(String docId, MouvementCaisse mvtCaisse) async {
    final mvtCaisseService = ref.watch(mvtCaisseServiceProvider);
    mvtCaisseService.update(docId, mvtCaisse);
  }
}

class MouvementCaisseService {
  final CollectionReference mouvementsCaisse =
      FirebaseFirestore.instance.collection('mouvements_caisse');

  void add(MouvementCaisse mvtCaisse) async {
    await mouvementsCaisse.add(mvtCaisse.toJson());
    Utils.showSuccessMessage(message: "Mouvement caisse enregistré!");
  }

  void delete(String docId) async {
    mouvementsCaisse.doc(docId).delete();
  }

  void update(String docId, MouvementCaisse mvtCaisse) async {
    mouvementsCaisse.doc(docId).update(mvtCaisse.toJson());
  }

  Future<QuerySnapshot> fetchMvts(String caisseId) async {
    final query = mouvementsCaisse
        .orderBy('dateMaj', descending: true)
        .where('caisseId', isEqualTo: caisseId);

    final result = await query.get();

    return result;
  }

  Stream<QuerySnapshot> streamMvts(String caisseId) {
    return mouvementsCaisse
        .where('caisseId', isEqualTo: caisseId)
        .orderBy('dateMaj', descending: true)
        .snapshots();
  }
}
