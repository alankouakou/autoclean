import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/features/tarification/services/tarif_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiTarif = Provider<TarifService>((ref) => TarifService());

final tarifsFutureProvider = FutureProvider<List<Tarif>>(
  (ref) async {
    final tarifService = ref.watch(apiTarif);
    return await tarifService.getTarifs();
  },
);

final selectedTarifName = StateProvider<String>((ref) => 'Basique');

final selectedTarif = FutureProvider<Tarif>((ref) async {
  final libelleTarif = ref.watch(selectedTarifName);
  final tarifService = ref.watch(apiTarif);

  return await tarifService.getTarif(libelleTarif);
});
