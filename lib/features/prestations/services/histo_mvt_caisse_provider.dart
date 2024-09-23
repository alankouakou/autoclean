import 'dart:async';

import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mouvement_caisse.dart';
import 'mvt_caisse_service.dart';

final histoCaisseIdProvider = StateProvider<String>((ref) => '');

final mvtsCaisseProvider =
    AsyncNotifierProvider<MvtCaisseNotifier, List<MouvementCaisse>>(
        MvtCaisseNotifier.new);

final histoMvtsCaisseProvider =
    AsyncNotifierProvider<HistoMvtCaisseNotifier, List<MouvementCaisse>>(
        HistoMvtCaisseNotifier.new);

class HistoMvtCaisseNotifier extends AsyncNotifier<List<MouvementCaisse>> {
  final mvtCaisseService = MouvementCaisseService();
  @override
  FutureOr<List<MouvementCaisse>> build() async {
    final caisseId = ref.watch(histoCaisseIdProvider);
    final mvtCaisseSnapshot = await mvtCaisseService.fetchMvts(caisseId);
    return mvtCaisseSnapshot.docs
        .map((item) => MouvementCaisse.fromFirestore(docu: item))
        .toList();
  }
}

class MvtCaisseNotifier extends AsyncNotifier<List<MouvementCaisse>> {
  final mvtCaisseService = MouvementCaisseService();
  @override
  FutureOr<List<MouvementCaisse>> build() async {
    final caisseId = ref.watch(caisseIdProvider);
    final mvtCaisseSnapshot = await mvtCaisseService.fetchMvts(caisseId);
    return mvtCaisseSnapshot.docs
        .map((item) => MouvementCaisse.fromFirestore(docu: item))
        .toList();
  }
}
