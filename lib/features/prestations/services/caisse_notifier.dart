import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final caisseNotifierProvider =
    NotifierProvider<CaisseNotifier, Caisse>(() => CaisseNotifier());

class CaisseNotifier extends Notifier<Caisse> {
  @override
  Caisse build() {
    var dateOuverture = DateTime.now();

    return Caisse(
      id: 1,
      libelle: 'Journee du $dateOuverture',
      caissier: '',
      soldeCaisse: 0,
    );
  }

  void open(double solde) {
    state.dateOuverture = DateTime.now();
    state.soldeCaisse = solde;
  }

  void close(double solde) {
    state.dateFermeture = DateTime.now();
    state.soldeCaisse = solde;
  }

  add(double amount) {
    state.soldeCaisse += amount;
  }

  withdraw(double amount) {
    state.soldeCaisse -= amount;
  }

  setCaissier(String name) {
    state.caissier = name;
  }

  reset() {
    state.soldeCaisse = 0;
  }

  double solde() {
    return state.soldeCaisse;
  }

  String nomCaissier() {
    return capitalize(state.caissier);
  }

  @override
  String toString() {
    return 'Caisse ${state.caissier} ${state.soldeCaisse} FCFA ouvert à ${state.dateOuverture}';
  }
}
