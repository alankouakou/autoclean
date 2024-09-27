import 'dart:ui';

import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:autoclean/features/prestations/pages/saisie_mvt_caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/mvt_caisse_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListMvtsCaisse extends ConsumerWidget {
  const ListMvtsCaisse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mvtCaisseNotifier = ref.watch(mvtCaisseNotifierProvider);
    final caisseNotifier = ref.watch(caisseNotifierProvider);
    double totalMvtsEntree = 0;
    double totalMvtsSortie = 0;

    mvtCaisseNotifier.when(
        data: (data) {
          totalMvtsEntree = data
              .where((m) => m.typeMouvement == 'Entree')
              .fold(0.0, (acc, m) => acc + m.montant);

          totalMvtsSortie = data
              .where((m) => m.typeMouvement == 'Sortie')
              .fold(0.0, (acc, m) => acc + m.montant);
        },
        loading: () {},
        error: (e, s) {});

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(children: [
        caisseNotifier.when(
            data: (caisse) => Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mouvements de caisse ',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5.0),
                      const Text("Date d'ouverture de la caisse",
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 5.0),
                      Text(Utils.dateFull.format(caisse.dateOuverture!),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5.0),
                      Text(
                          'Total Entrées : ${Utils.formatCFA(totalMvtsEntree)}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                          )),
                      Text(
                          'Total Sorties  : ${Utils.formatCFA(totalMvtsSortie)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          )),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SaisieMvtCaisse()));
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50.0),
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ajouter',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              SizedBox(width: 10.0),
                              Icon(Icons.add_box, color: Colors.white)
                            ],
                          )),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Center(child: CircularProgressIndicator())),
        const SizedBox(height: 10),
        Expanded(
          child: mvtCaisseNotifier.when(
              data: (listeMvts) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListView.builder(
                      itemCount: listeMvts.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return infosDialog(listeMvts[index], context);
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: ListTile(
                                leading:
                                    listeMvts[index].typeMouvement == 'Entree'
                                        ? const Icon(Icons.arrow_forward,
                                            color: Colors.teal)
                                        : const Icon(Icons.arrow_back,
                                            color: Colors.red),
                                title: Text(
                                    '${Utils.timeShort.format(listeMvts[index].dateMaj)} - ${listeMvts[index].details}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: Text(
                                    Utils.formatCFA(listeMvts[index].montant),
                                    style: const TextStyle(fontSize: 14))),
                          ),
                        ),
                      ),
                    ),
                  ),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator())),
        ),
      ]),
    );
  }

  Widget infosDialog(MouvementCaisse mvtCaisse, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      height: 200,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mvtCaisse.details,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Type mouvement: ${mvtCaisse.typeMouvement}'),
          Text('Montant: ${Utils.formatCFA(mvtCaisse.montant)}'),
          Text(Utils.dateFull.format(mvtCaisse.dateMaj)),
          const SizedBox(height: 20.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: const Text('OK', style: TextStyle(color: Colors.white))),
          ])
        ],
      ),
    );
  }
}
