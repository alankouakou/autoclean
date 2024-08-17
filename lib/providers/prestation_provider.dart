import 'package:autoclean/models/prestation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Cette classe est utilisée à des fins de démo
/// pour charger des données tests générées à la volée
///
/// A terme, les données proviendront d'un backend via une API

final df = DateFormat('d/M/y HH:mm:ss');

final prestationsNotifierProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

class PrestationsNotifier extends Notifier<List<Prestation>> {
  final prestations = <Prestation>[];
  @override
  List<Prestation> build() {
/*
    DateTime vDate = DateTime.now();
    final maxValue = Random().nextInt(30);
    if (prestations.isEmpty) {
      for (var i = 0; i < maxValue; i++) {
        vDate = vDate.subtract(const Duration(seconds: 292));
        var libelle = i % 5 == 0 ? 'Premium' : 'Standard';
        var prix = i % 5 == 0 ? 5000.0 : 2000.0;
        print('Nouvelle date $i: ${df.format(vDate)}');
        Prestation p = Prestation(
            id: i,
            libelle: libelle,
            prix: prix,
            montantRecu: prix,
            monnaie: 0,
            annulee: false,
            datePrestation: vDate,
            detailsVehicule: '');

        prestations.add(p);
      }
    }
*/

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
}
