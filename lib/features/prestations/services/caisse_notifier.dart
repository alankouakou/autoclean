import 'dart:async';

import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

//Id de la caisse en cours
final caisseIdProvider = StateProvider<String>((ref) => '');

final caisseNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CaisseNotifier, Caisse>(
        CaisseNotifier.new);

class CaisseNotifier extends AutoDisposeAsyncNotifier<Caisse> {
  @override
  FutureOr<Caisse> build() {
    return fetchCaisse();
  }

  Future<Caisse> fetchCaisse() async {
    final auth = ref.watch(authProvider);
    final caisseService = ref.watch(caisseProvider);
    final userUID = auth.currentUser!.uid;
    String id;

    //Récuperer l'id de la caisse ouverte
    id = await caisseService.getIdCaisseOuverte(userAccountId: userUID) ?? '';
    //si l'Id est non nul, Recuperer la caisse
    if (id.isEmpty) {
      id = await caisseService.createNew(userUID);
    }
    ref.read(caisseIdProvider.notifier).state = id;
    print('fetch caisse - caisse ID : $id');
    return fetchById(id);
    // Si l'id est nul, réer une nlle caisse et la récuperer
  }

  Future<Caisse> fetchById(String id) async {
    final caisseService = ref.watch(caisseProvider);
    final caisse = await caisseService.getById(id);
    return caisse;
  }

  Future<String> maj(Caisse newValue, String id) async {
    final caisseService = ref.watch(caisseProvider);
    final caisseId = await caisseService.update(newValue, id);
    return caisseId;
  }

  void setCaisse(String caisseId) async {}
}
