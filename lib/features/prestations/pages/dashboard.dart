import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:autoclean/features/prestations/services/prestation_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../laveurs/services/laveur_notifier.dart';
import '../../printing/services/printing_service.dart';
import '../models/prestation.dart';
import '../services/histo_mvt_caisse_provider.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final DateTime dateOuverture;
    final firestoreService = FirestoreService();

    final auth = AuthService();
    final prestations = ref.watch(prestationsStreamProvider);
    final halfScreenwidth = (MediaQuery.of(context).size.width - 26) / 2;
    final futureCaisse = ref.watch(caisseNotifierProvider);
    String caisseId = ref.watch(caisseIdProvider);
    final mvtsCaisse = ref.watch(mvtsCaisseProvider);
    double totalMvts = 0.0;
    double totalRecette = 0.0;
    double soldeCaisse = 0.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
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
            title: const Text('Tableau de bord',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.teal))),
        body: TabBarView(children: [
          Container(
            color: Colors.grey.shade100,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  futureCaisse.when(
                    data: (caisse) {
                      //caisseId = caisse.id!;
                      dateOuverture = caisse.dateOuverture!;
                      return sessionWidget(
                          dateOuverture, DateTime.now(), halfScreenwidth);
                    },
                    error: (e, s) => Container(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 10.0),
                  mvtsCaisse.when(
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
                  prestations.when(
                    data: (value) {
                      final prestations = value.docs
                          .where(
                              (element) => element['accountId'] == auth.userId)
                          .where((element) => element['caisseId'] == caisseId)
                          .map((e) => Prestation.fromFirestore(e))
                          .toList();
                      final somme =
                          prestations.fold(0.0, (acc, p) => acc + p.prix);
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800)),
                                trailing: Text(Utils.formatCFA(soldeCaisse),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18))),
                          ),
                        ],
                      );
                    },
                    error: (e, s) => Container(),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  color: Colors.white,
                  width: double.infinity,
                  height: 50,
                  child: Center(
                      child: mvtsCaisse.when(
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
              mvtsCaisse.when(
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
                                  leading: mvtCaisse.typeMouvement == "Sortie"
                                      ? const Icon(Icons.arrow_back,
                                          color: Colors.red)
                                      : const Icon(Icons.arrow_forward,
                                          color: Colors.green),
                                  title: Text(
                                      '${Utils.timeShort.format(mvtCaisse.dateMaj)} - ${mvtCaisse.details}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14)),
                                  trailing: mvtCaisse.typeMouvement == "Sortie"
                                      ? Text(
                                          '-${Utils.formatCFA(mvtCaisse.montant)}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.red))
                                      : Text(Utils.formatCFA(mvtCaisse.montant),
                                          style: const TextStyle(fontSize: 14)),
                                ),
                              );
                            }));
                  },
                  error: (e, s) => const Text('Une erreur est survenue'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()))
            ],
          ),
          Container(
              color: Colors.grey.shade100,
              child: Column(children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: prestations.when(
                        data: (value) {
                          final prestations = value.docs
                              .where((element) =>
                                  element['accountId'] == auth.userId)
                              .where(
                                  (element) => element['caisseId'] == caisseId)
                              .map((e) => Prestation.fromFirestore(e))
                              .toList();
                          final somme =
                              prestations.fold(0.0, (acc, p) => acc + p.prix);
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getPrestations(),
                      builder: (context, snapshot) {
                        //  print(
                        //      'Inside StreamBuilder fireBaseAuthId: $accountUserId, caisse:$caisseId');

                        if (snapshot.hasData) {
                          final prestations = snapshot.data!.docs
                              .where((element) =>
                                  element['accountId'] == auth.userId)
                              .where(
                                  (element) => element['caisseId'] == caisseId)
                              .toList();
                          return ListView.builder(
                            itemCount: prestations.length,
                            itemBuilder: (context, index) {
                              final prestation =
                                  Prestation.fromFirestore(prestations[index]);
                              return GestureDetector(
                                onLongPress: () async {
                                  final nomLaveur = await ref
                                      .read(laveurProvider.notifier)
                                      .getNameById(prestation.laveur);
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            alignment: Alignment.topCenter,
                                            width: double.infinity,
                                            height: 400,
                                            //height: 300,
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      prestation
                                                          .detailsVehicule,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 10),
                                                  Text(prestation.libelle,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      Utils.formatCFA(
                                                          prestation.prix),
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(Utils.dateFull.format(
                                                      prestation
                                                          .datePrestation)),
                                                  Text('Laveur: $nomLaveur',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 10),
                                                  Text(prestation.caisseId!),
                                                  Text(prestation.accountId),
                                                  const SizedBox(height: 30),
                                                  IconButton(
                                                      onPressed: () {
                                                        PrintingService
                                                            .printReceipt(
                                                                prestation);
                                                      },
                                                      icon: const Icon(
                                                          size: 30.0,
                                                          Icons.print,
                                                          color: Color(
                                                              0xFFF3774D))),
                                                  const SizedBox(height: 20),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.blue),
                                                      child: const Text(
                                                          'Fermer',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                  const SizedBox(
                                                    height: 10,
                                                  )
                                                ]),
                                          ));
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5.0),
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: Text(
                                        Utils.timeShort
                                            .format(prestation.datePrestation),
                                        style: const TextStyle(
                                            color: Color(0xFFF3774D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    title: Text(prestation.detailsVehicule,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14)),
                                    trailing: Text(
                                        Utils.formatCFA(prestation.prix),
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Text('No data');
                        }
                      }),
                ),
              ]))
        ]),
      ),
    );
  }

  Widget sessionWidget(
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
                  const Text('Ouvert depuis:',
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
            child: const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fermeture:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF3774D))),
                  Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('',
                      style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFFF3774D),
                          fontWeight: FontWeight.bold))
                ],
              ),
            )),
      ]),
    );
  }

  void infosPrestation(BuildContext context, Prestation prestation) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: 350,
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
