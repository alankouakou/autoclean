import 'dart:math';

import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/providers/caisse_notifier.dart';
import 'package:autoclean/providers/tarifs_provider.dart';
import 'package:autoclean/features/prestations/pages/saisie_prestation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionTarifWidget extends ConsumerWidget {
  const OptionTarifWidget(
      {super.key, required this.option, required this.couleur});
  final Option option;
  final Color couleur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTarrifName = ref.watch(selectedTarifName);
    //final nomTarif = ref.watch(selectedTarifName);
    return ActionChip(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Text(option.libelle,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: couleur.withOpacity(0.8),
        avatar: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black.withOpacity(0.2),
            child: Text(option.libelle[0],
                style: const TextStyle(color: Colors.white, fontSize: 12))),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Wrap(runSpacing: 15, spacing: 4, children: [
                        Container(
                            alignment: Alignment.center,
                            child: Text(currentTarrifName,
                                style: TextStyle(
                                    color: couleur,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold))),
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                                '${option.libelle} : ${formatCFA(option.prix)}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 30, right: 30),
                                hintText: 'Immatriculation, marque vehicule',
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                fillColor: Colors.grey.shade300)),
                        TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 30, right: 30),
                                hintText: 'Montant reçu',
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                fillColor: Colors.grey.shade300)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white),
                                  child: const Text('Annuler')),
                              ElevatedButton(
                                  onPressed: () {
                                    var p = Prestation(
                                        id: Random().hashCode,
                                        libelle:
                                            '$currentTarrifName - ${option.libelle}',
                                        prix: option.prix,
                                        montantRecu: option.prix,
                                        monnaie: 0.0,
                                        annulee: false,
                                        datePrestation: DateTime.now(),
                                        detailsVehicule: '');
                                    ref.read(prestationsProvider.notifier)
                                      ..add(p)
                                      ..save();

                                    //met à jour le solde de caisse
                                    ref
                                        .read(caisseNotifierProvider.notifier)
                                        .add(option.prix);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: couleur,
                                      foregroundColor: Colors.white),
                                  child: const Text('Valider'))
                            ])
                      ]))));
        });
  }
}
