import 'dart:math';

import 'package:autoclean/components/tarif_chips_widget.dart';
import 'package:autoclean/components/options_tarif_widget.dart';
import 'package:autoclean/models/prestation.dart';
import 'package:autoclean/models/tarifs.dart';
import 'package:autoclean/providers/prestation_provider.dart';
import 'package:autoclean/providers/tarifs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:autoclean/core/utils.dart';
import 'package:autoclean/core/constants.dart';

final prestationsProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

final df = DateFormat('HH:mm:ss');

class SaisiePrestation extends ConsumerWidget {
  const SaisiePrestation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listeTarifs = ref.watch(tarifsFutureProvider);
    final prestations = ref.watch(prestationsProvider);
    final soldeCaisse = ref.watch(prestationsProvider.notifier).totalCA();
    final nbClients = ref.watch(prestationsProvider.notifier).count();
    final optionsTarif = ref.watch(selectedTarif);

    List<Tarif> allTarrifs = <Tarif>[];

    double sectionWidth = (MediaQuery.of(context).size.width - 80) / 4;
    //double soldeCaisse = 0;
    listeTarifs.when(
      data: (tarifs) {
        allTarrifs = tarifs;
      },
      error: (error, stackTrace) {},
      loading: () {},
    );

    return Scaffold(
        body: Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    //padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 114,
                    width: sectionWidth,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Clients',
                              style: TextStyle(
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.bold)),
                          Text('$nbClients',
                              style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 114,
                    width: sectionWidth * 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Prestations',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF3774D))),
                          Text(formatCFA(soldeCaisse),
                              style: const TextStyle(
                                  fontSize: 26,
                                  color: Color(0xFFF3774D),
                                  fontWeight: FontWeight.bold)),
                          const Text('',
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                ]),
          ),

          // Liste tarifs
          TarifChips(tarifs: allTarrifs.map((t) => t.libelle).toList()),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            width: double.infinity,
            child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: optionsTarif.when(
                    data: (currentTarrif) {
                      return currentTarrif.options
                          .map((option) => OptionTarifWidget(
                                option: option,
                                couleur: couleurs[
                                    Random().nextInt(couleurs.length - 1)],
                              ))
                          .toList();
                    },
                    error: (error, stackTrace) {
                      return [
                        Text(stackTrace.toString(),
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold))
                      ];
                    },
                    loading: () => [const CircularProgressIndicator()])),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: prestations.length,
            itemBuilder: (context, index) {
              return Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.white,
                  child: ListTile(
                    leading: Text(df.format(prestations[index].datePrestation),
                        style: const TextStyle(
                            color: Color(0xFFF3774D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    title: Text(prestations[index].libelle,
                        style: const TextStyle(fontSize: 14)),
                    //subtitle: Text(prestations[index].detailsVehicule),
                    trailing: Text(formatCFA(prestations[index].prix),
                        style: const TextStyle(fontSize: 14)),
                  ));
            },
          )),
        ],
      ),
    ));
  }
}
