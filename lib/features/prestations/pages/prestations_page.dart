import 'dart:math';

import 'package:autoclean/features/authentification/services/auth_service.dart';

import 'package:autoclean/features/prestations/pages/point_caisse.dart';
import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:autoclean/features/printing/services/printing_service.dart';
import 'package:autoclean/features/tarification/pages/widgets/tarif_chips_widget.dart';
import 'package:autoclean/features/tarification/pages/widgets/options_tarif_widget.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/prestation_provider.dart';
import 'package:autoclean/features/tarification/services/tarifs_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoclean/core/utils.dart';
import 'package:autoclean/core/constants.dart';

final prestationsProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

class PrestationsPage extends ConsumerWidget {
  const PrestationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listeTarifs = ref.watch(tarifsFutureProvider);
    final firestoreService = FirestoreService();
    final optionsTarif = ref.watch(selectedTarif);
    final authService = ref.watch(authProvider);
    final futureCaisse = ref.watch(caisseNotifierProvider);

    String accountUserId = '';
    DateTime dateOuverture = DateTime(2024, 01, 01);

    final streamPrestations = ref.watch(prestationsStreamProvider);
    List<Tarif> allTarrifs = <Tarif>[];
    List<Prestation> prmListePrestations = <Prestation>[];

    //Totaux
    int totalClients = 0;
    double montantTotalPrestations = 0;

    try {
      accountUserId = authService.currentUser!.uid;
    } catch (e) {
      print('Error when getting current user uid: ${e.toString()}');
    }
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
            child: futureCaisse.when(
                data: (data) {
                  print(
                      'inside build: caisse UID: ${data.accountId}, ${data.caissier}, ouvert à ${Utils.dateFull.format(data.dateOuverture!)} ');
                  final caisseId = data.id;
                  dateOuverture = data.dateOuverture!;
                  return Column(
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, right: 10),
                                //padding: const EdgeInsets.only(left: 10, right: 10),
                                height: 114,
                                width: sectionWidth,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Clients',
                                          style: TextStyle(
                                              color: Colors.teal.shade800,
                                              fontWeight: FontWeight.bold)),
                                      streamPrestations.when(data: (data) {
                                        prmListePrestations = data.docs
                                            .map((d) =>
                                                Prestation.fromFirestore(d))
                                            .where(
                                                (p) => p.caisseId == caisseId)
                                            .toList();
                                        var total = data.docs
                                            .where((element) =>
                                                element['accountId'] ==
                                                accountUserId)
                                            .where((element) =>
                                                element['caisseId'] == caisseId)
                                            .length;
                                        totalClients = total;
                                        return Text(totalClients.toString(),
                                            style: const TextStyle(
                                                fontSize: 40,
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold));
                                      }, error: (e, s) {
                                        return const Text(
                                            'Une erreur est survenue!');
                                      }, loading: () {
                                        return const CircularProgressIndicator();
                                      })
                                    ]),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                height: 114,
                                width: sectionWidth * 3,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Prestations',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF3774D))),
                                      streamPrestations.when(data: (data) {
                                        montantTotalPrestations = data.docs
                                            .where((element) =>
                                                element['accountId'] ==
                                                accountUserId)
                                            .where((element) =>
                                                element['caisseId'] == caisseId)
                                            .toList()
                                            .fold(0.0, (acc, p) {
                                          return acc + p['prix'];
                                        });
                                        return Text(
                                            Utils.formatCFA(
                                                montantTotalPrestations),
                                            style: const TextStyle(
                                                fontSize: 26,
                                                color: Color(0xFFF3774D),
                                                fontWeight: FontWeight.bold));
                                      }, error: (e, s) {
                                        return const Text(
                                            'Une erreur est survenue');
                                      }, loading: () {
                                        return const CircularProgressIndicator();
                                      }),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PointCaisse(
                                                          dateOuverture:
                                                              dateOuverture,
                                                          nombrePrestations:
                                                              totalClients,
                                                          montantTotalPrestations:
                                                              montantTotalPrestations,
                                                          listePrestations:
                                                              prmListePrestations,
                                                        )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: const BorderSide(
                                                      color:
                                                          Color(0xFFF3774D))),
                                              backgroundColor: Colors.white,
                                              foregroundColor:
                                                  const Color(0xFFF3774D)),
                                          child: const Text('Point de caisse'))
                                    ]),
                              ),
                            ]),
                      ),

                      // Liste tarifs
                      TarifChips(
                          tarifs: allTarrifs.map((t) => t.libelle).toList()),
                      SizedBox(
                          height: 50,
                          child: optionsTarif.when(
                              data: (tarif) {
                                return ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: tarif.options
                                        .map((option) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: OptionTarifWidget(
                                                option: option,
                                                couleur: couleurs[Random()
                                                    .nextInt(
                                                        couleurs.length - 1)],
                                              ),
                                            ))
                                        .toList());
                              },
                              error: (e, s) => null,
                              loading: () => const Center(
                                  child: CircularProgressIndicator()))),

                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: firestoreService.getPrestations(),
                            builder: (context, snapshot) {
                              //  print(
                              //      'Inside StreamBuilder fireBaseAuthId: $accountUserId, caisse:$caisseId');

                              if (snapshot.hasData) {
                                final prestations = snapshot.data!.docs
                                    .where((element) =>
                                        element['accountId'] == accountUserId)
                                    .where((element) =>
                                        element['caisseId'] == caisseId)
                                    .toList();
                                return ListView.builder(
                                  itemCount: prestations.length,
                                  itemBuilder: (context, index) {
                                    final prestation = Prestation.fromFirestore(
                                        prestations[index]);
                                    return GestureDetector(
                                      onLongPress: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  alignment:
                                                      Alignment.topCenter,
                                                  width: double.infinity,
                                                  height: 350,
                                                  //height: 300,
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            prestation
                                                                .detailsVehicule,
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        const SizedBox(
                                                            height: 10),
                                                        Text(prestation.libelle,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            Utils.formatCFA(
                                                                prestation
                                                                    .prix),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(Utils.dateFull
                                                            .format(prestation
                                                                .datePrestation)),
                                                        const SizedBox(
                                                            height: 10),
                                                        Text(prestation
                                                            .caisseId!),
                                                        Text(prestation
                                                            .accountId),
                                                        const SizedBox(
                                                            height: 30),
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
                                                        const SizedBox(
                                                            height: 20),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blue),
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
                                              Utils.timeShort.format(
                                                  prestation.datePrestation),
                                              style: const TextStyle(
                                                  color: Color(0xFFF3774D),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          title: Text(
                                              prestation.detailsVehicule,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          //subtitle: Text(prestations[index].detailsVehicule),
                                          trailing: Text(
                                              Utils.formatCFA(prestation.prix),
                                              style: const TextStyle(
                                                  fontSize: 14)),
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
                    ],
                  );
                },
                error: ((error, stackTrace) => Text(stackTrace.toString())),
                loading: () =>
                    const Center(child: CircularProgressIndicator()))));
  }
}


                      /*
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
                                            couleur: couleurs[Random()
                                                .nextInt(couleurs.length - 1)],
                                          ))
                                      .toList();
                                },
                                error: (error, stackTrace) {
                                  return [
                                    Text(stackTrace.toString(),
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold))
                                  ];
                                },
                                loading: () =>
                                    [const CircularProgressIndicator()])),
                      ),
                      */