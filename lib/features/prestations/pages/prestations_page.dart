import 'dart:math';

import 'package:autoclean/features/prestations/services/firestore_service.dart';
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
import 'package:intl/intl.dart';
import 'package:autoclean/core/utils.dart';
import 'package:autoclean/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prestationsProvider =
    NotifierProvider<PrestationsNotifier, List<Prestation>>(
        PrestationsNotifier.new);

final df = DateFormat('HH:mm:ss');
final dfFull = DateFormat('dd/MM/yyyy HH:mm:ss');

class PrestationsPage extends ConsumerWidget {
  const PrestationsPage({this.accountId, super.key});
  final String? accountId;

  Future<String> getUserUID() async {
    var sp = await SharedPreferences.getInstance();
    return sp.getString('firebase_auth_uid')!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listeTarifs = ref.watch(tarifsFutureProvider);
    final firestoreService = FirestoreService();
    final optionsTarif = ref.watch(selectedTarif);
    final caissier = ref.watch(caisseNotifierProvider.notifier).nomCaissier();
    final caisse = ref.watch(caisseNotifierProvider);

    final streamPrestations = ref.watch(prestationsStreamProvider);
    String firebaseAuthId = '';
    getUserUID().then((value) => firebaseAuthId = value);
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
                          streamPrestations.when(data: (data) {
                            var total = data.docs
                                .where((element) =>
                                    element['accountId'] == accountId)
                                .length;
                            return Text(total.toString(),
                                style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold));
                          }, error: (e, s) {
                            return const Text('Une erreur est survenue!');
                          }, loading: () {
                            return const CircularProgressIndicator();
                          })
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
                          streamPrestations.when(data: (data) {
                            var somme = data.docs
                                .map((e) => Prestation.fromFirestore(e))
                                .where(
                                    (element) => element.accountId == accountId)
                                .toList()
                                .fold(0.0, (acc, p) {
                              return acc + p.prix;
                            });
                            return Text(formatCFA(somme),
                                style: const TextStyle(
                                    fontSize: 26,
                                    color: Color(0xFFF3774D),
                                    fontWeight: FontWeight.bold));
                          }, error: (e, s) {
                            return const Text('Une erreur est survenue');
                          }, loading: () {
                            return const CircularProgressIndicator();
                          }),
                          Text('$caissier ${caisse.soldeCaisse} FCFA',
                              style: const TextStyle(
                                  color: Color(0xFFF3774D),
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
            child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getPrestations(),
                builder: (context, snapshot) {
                  print('Inside StreamBuilder fireBaseAuthId: $firebaseAuthId');

                  if (snapshot.hasData) {
                    final prestations = snapshot.data!.docs
                        .where((element) => element['accountId'] == accountId)
                        .toList();
                    return ListView.builder(
                      itemCount: prestations.length,
                      itemBuilder: (context, index) {
                        final prestation = Prestation.fromJson(
                            prestations[index].data() as Map<String, dynamic>);
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(prestation.detailsVehicule,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  '${prestation.libelle} ${formatCFA(prestation.prix)}'),
                                              Text(dfFull.format(
                                                  prestation.datePrestation)),
                                              const SizedBox(height: 30),
                                            ]),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              child: const Text('Fermer',
                                                  style: TextStyle(
                                                      color: Colors.white)))
                                        ]));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            color: Colors.white,
                            child: ListTile(
                              leading: Text(
                                  df.format(prestation.datePrestation),
                                  style: const TextStyle(
                                      color: Color(0xFFF3774D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              title: Text(prestation.libelle,
                                  style: const TextStyle(fontSize: 14)),
                              //subtitle: Text(prestations[index].detailsVehicule),
                              trailing: Text(formatCFA(prestation.prix),
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
        ],
      ),
    ));
  }
}
