import 'package:autoclean/features/laveurs/services/laveur_notifier.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/histo_prestation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../printing/services/printing_service.dart';
import '../models/caisse.dart';
import '../models/mouvement_caisse.dart';
import '../models/prestation.dart';
import '../services/caisse_service.dart';
import '../services/histo_mvt_caisse_provider.dart';

class HistoriqueCaisse extends ConsumerWidget {
  const HistoriqueCaisse(
      {required this.dateOuverture, required this.dateFermeture, super.key});
  final DateTime dateOuverture;
  final DateTime dateFermeture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caisseRefId = ref.watch(histoCaisseIdProvider);
    final asyncValuePrestations = ref.watch(histoPrestationsProvider);
    final asyncValueMvtsCaisse = ref.watch(histoMvtsCaisseProvider);
    final halfScreenwidth = (MediaQuery.of(context).size.width - 26) / 2;

    double totalMvts = 0.0;
    double totalRecette = 0.0;
    double soldeCaisse = 0.0;
    List<MouvementCaisse> mvtCaisses = [];
    List<Prestation> prestations = [];
    bool isWaitingPrint = false;

    asyncValueMvtsCaisse.when(
      data: (data) {
        mvtCaisses = data;
      },
      error: (e, s) {},
      loading: () => const Center(child: CircularProgressIndicator()),
    );

    asyncValuePrestations.when(
      data: (data) {
        prestations = data;
      },
      error: (e, s) {
        print(e.toString());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );

    //late final Caisse caisse;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Recap',
                  icon: Icon(Icons.summarize, color: Colors.lightBlue),
                ),
                Tab(
                  text: 'Mouvts caisse',
                  icon: Icon(Icons.payments, color: Colors.green),
                ),
                Tab(
                  text: 'Lavage',
                  icon: Icon(Icons.local_car_wash, color: Colors.orange),
                ),
              ],
            ),
            title:
                Text('Historique du ${Utils.dateShort.format(dateOuverture)}')),
        body: TabBarView(children: [
          Container(
            color: Colors.grey.shade100,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  openCloseHoursWidget(
                      dateOuverture, dateFermeture, halfScreenwidth),
                  const SizedBox(height: 10.0),
                  asyncValueMvtsCaisse.when(
                      data: (data) {
                        final totalEntrees = data
                            .where((m) => m.typeMouvement == 'Entree')
                            .fold(0.0, (acc, m) => acc + m.montant);
                        final totalSorties = data
                            .where((m) => m.typeMouvement == 'Sortie')
                            .fold(0.0, (acc, m) => acc + m.montant);
                        totalMvts = totalEntrees - totalSorties;
                        return Column(children: [
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            color: Colors.white,
                            child: ListTile(
                                title: Text('Total Entrées caisse',
                                    style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800)),
                                trailing: Text(Utils.formatCFA(totalEntrees),
                                    style: const TextStyle(fontSize: 14))),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            color: Colors.white,
                            child: ListTile(
                                title: Text('Total Sorties caisse',
                                    style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        color: Colors.red.shade800)),
                                trailing: Text(
                                    ' -${Utils.formatCFA(totalSorties)}',
                                    style: const TextStyle(fontSize: 14))),
                          ),
                        ]);
                      },
                      error: (e, s) => const Text('Une erreur est survenue!'),
                      loading: () =>
                          const Center(child: CircularProgressIndicator())),
                  asyncValuePrestations.when(
                      data: (data) {
                        final somme = data.fold(0.0, (acc, p) => acc + p.prix);
                        totalRecette = somme;
                        soldeCaisse = totalRecette + totalMvts;

                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5.0),
                              color: Colors.white,
                              child: ListTile(
                                  title: Text('Total Prestations ',
                                      style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800)),
                                  trailing: Text(Utils.formatCFA(somme),
                                      style: const TextStyle(fontSize: 14))),
                            ),
                            Container(
                              margin: const EdgeInsets.all(5.0),
                              color: Colors.white,
                              child: ListTile(
                                  title: Text('Solde Caisse ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800)),
                                  trailing: Text(Utils.formatCFA(soldeCaisse),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold))),
                            ),
                          ],
                        );
                      },
                      error: (e, s) => const Placeholder(),
                      loading: () =>
                          const Center(child: CircularProgressIndicator())),
                  if (isWaitingPrint == true)
                    const Center(child: CircularProgressIndicator()),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      child: const Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        isWaitingPrint = true;
                        final caisseService = ref.watch(caisseProvider);
                        final caisse = await caisseService.getById(caisseRefId);
                        PrintingService.printDailyReport(
                            caisse, mvtCaisses, prestations);
                        isWaitingPrint = false;
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFF3774D),
                          side: const BorderSide(
                              width: 1, color: Color(0xFFF3774D)),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      child: const Text('Fermer',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: 50,
                      child: Center(
                          child: asyncValueMvtsCaisse.when(
                              data: (data) {
                                final totalEntrees = data
                                    .where((m) => m.typeMouvement == 'Entree')
                                    .fold(0.0, (acc, m) => acc + m.montant);
                                final totalSorties = data
                                    .where((m) => m.typeMouvement == 'Sortie')
                                    .fold(0.0, (acc, m) => acc + m.montant);
                                return ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      color: Colors.white,
                                      child: Text(
                                          'Entrées: ${Utils.formatCFA(totalEntrees)}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green.shade800)),
                                    ),
                                    Expanded(child: Container()),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      color: Colors.white,
                                      child: Text(
                                          'Sorties: -${Utils.formatCFA(totalSorties)}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                              error: (e, s) =>
                                  const Text('Une erreur est survenue'),
                              loading: () => const Center(
                                  child: CircularProgressIndicator())))),
                  asyncValueMvtsCaisse.when(
                      data: (data) {
                        return Expanded(
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final mvtCaisse = data[index];
                                  return Container(
                                    margin: const EdgeInsets.all(5.0),
                                    color: Colors.white,
                                    child: ListTile(
                                      leading:
                                          mvtCaisse.typeMouvement == "Sortie"
                                              ? const Icon(Icons.arrow_back,
                                                  color: Colors.red)
                                              : const Icon(Icons.arrow_forward,
                                                  color: Colors.green),
                                      title: Text(
                                          '${Utils.timeShort.format(mvtCaisse.dateMaj)} - ${mvtCaisse.details}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14)),
                                      trailing: mvtCaisse.typeMouvement ==
                                              "Sortie"
                                          ? Text(
                                              '-${Utils.formatCFA(mvtCaisse.montant)}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red))
                                          : Text(
                                              Utils.formatCFA(
                                                  mvtCaisse.montant),
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                    ),
                                  );
                                }));
                      },
                      error: (e, s) => const Text('Une erreur est survenue'),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()))
                ],
              )),
          Container(
              color: Colors.grey.shade100,
              child: Column(children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: asyncValuePrestations.when(
                        data: (data) {
                          final somme =
                              data.fold(0.0, (acc, p) => acc + p.prix);
                          return Text(
                              'Total Prestations: ${Utils.formatCFA(somme)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue.shade800));
                        },
                        error: (e, s) => const Placeholder(),
                        loading: () =>
                            const Center(child: CircularProgressIndicator())),
                  ),
                ),
                asyncValuePrestations.when(
                  data: (listPrestations) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: listPrestations.length,
                          itemBuilder: (context, index) {
                            final prestation = listPrestations[index];
                            return GestureDetector(
                              onLongPress: () async {
                                final nomLaveur = await ref
                                    .read(laveurProvider.notifier)
                                    .getNameById(prestation.laveur);
                                infosPrestation(context, prestation, nomLaveur);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5.0),
                                color: Colors.white,
                                child: ListTile(
                                    leading: Text(
                                        Utils.dateShort
                                            .format(prestation.datePrestation),
                                        style: const TextStyle(fontSize: 14)),
                                    title: Text(prestation.detailsVehicule,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14)),
                                    trailing: Text(
                                        Utils.formatCFA(prestation.prix),
                                        style: const TextStyle(fontSize: 14))),
                              ),
                            );
                          }),
                    );
                  },
                  error: (error, stackTrace) {
                    return Text(error.toString());
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                )
              ]))
        ]),
      ),
    );
  }

  Widget openCloseHoursWidget(
      DateTime dateOuverture, DateTime dateFermeture, double containerWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        SizedBox(
            width: containerWidth - 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ouverture:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  Text(Utils.dateShort.format(dateOuverture),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(Utils.timeFull.format(dateOuverture),
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold))
                ],
              ),
            )),
        Container(color: Colors.grey.withOpacity(0.5), height: 50, width: 2),
        SizedBox(
            width: containerWidth - 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fermeture:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF3774D))),
                  Text(Utils.dateShort.format(dateFermeture),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(Utils.timeFull.format(dateFermeture),
                      style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFFF3774D),
                          fontWeight: FontWeight.bold))
                ],
              ),
            )),
      ]),
    );
  }

  void infosPrestation(
      BuildContext context, Prestation prestation, String nomLaveur) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: 400,
              //height: 300,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(prestation.detailsVehicule,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(prestation.libelle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(Utils.formatCFA(prestation.prix),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(Utils.dateFull.format(prestation.datePrestation)),
                    Text('Laveur: $nomLaveur',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Text(prestation.caisseId!),
                    Text(prestation.accountId),
                    const SizedBox(height: 30),
                    IconButton(
                        onPressed: () {
                          PrintingService.printReceipt(prestation);
                        },
                        icon: const Icon(
                            size: 30.0, Icons.print, color: Color(0xFFF3774D))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text('Fermer',
                            style: TextStyle(color: Colors.white))),
                    const SizedBox(
                      height: 10,
                    )
                  ]),
            ));
  }
}
