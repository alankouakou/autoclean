import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/features/tarification/services/tarif_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiTarif = Provider<TarifService>((ref) => TarifService());

final tarifsFutureProvider = FutureProvider<List<Tarif>>(
  (ref) async {
    final tarifService = ref.watch(apiTarif);
    final auth = ref.watch(authProvider);
    final user_uid = auth.currentUser?.uid;
    print('in TarifProvider. user UID: $user_uid');
    var listTarifs = await tarifService.getListeTarifs(user_uid);
    // print('Liste tarifs');
    //print(listTarifs.map((e) => e.libelle).toList());
    return listTarifs;
  },
);

final selectedTarifName = StateProvider<String>((ref) => 'Basique');

final selectedTarif = FutureProvider<Tarif>((ref) async {
  final libelleTarif = ref.watch(selectedTarifName);
  final tarifService = ref.watch(apiTarif);

  return await tarifService.getTarif(libelleTarif);
});
