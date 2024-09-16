import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';
import 'package:autoclean/features/prestations/pages/histo_caisse.dart';
import 'package:autoclean/features/prestations/pages/historique_caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';
import 'package:autoclean/features/prestations/services/histo_mvt_caisse_provider.dart';
import 'package:autoclean/features/prestations/services/mvt_caisse_service.dart';
import 'package:autoclean/features/prestations/services/prestation_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/caisse_notifier.dart';

class CaissePage extends ConsumerStatefulWidget {
  const CaissePage({super.key});

  @override
  ConsumerState<CaissePage> createState() => _CaissePageState();
}

class _CaissePageState extends ConsumerState<CaissePage> {
  late final SharedPreferences sp;
  String accountId = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userUID = ref.watch(authProvider).currentUser!.uid;
    final caisseService = ref.watch(caisseProvider);
    print('Inside build method - accountId : $accountId');
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 5, right: 5),
      child: Column(children: [
        const Text('Récap. journées',
            style: TextStyle(
                fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: caisseService.getCaisses(userUID),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final caisses = snapshot.data!.docs
                      .where((e) => e['accountId'] == userUID)
                      .toList();
                  return ListView.builder(
                    itemCount: caisses.length,
                    itemBuilder: (context, index) {
                      final docId = caisses[index].id;
                      final caisse = Caisse.fromJson(
                          caisses[index].data() as Map<String, dynamic>);
                      return GestureDetector(
                        onTap: () {
                          ref.read(histoCaisseIdProvider.notifier).state =
                              docId;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HistoriqueCaisse(
                                  dateOuverture: caisse.dateOuverture!,
                                  dateFermeture:
                                      caisse.dateFermeture ?? DateTime.now())));
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20.0),
                              width: double.infinity,
                              height: 300,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(caisse.libelle,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Center(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(
                                              'De : ${Utils.dateFull.format(caisse.dateOuverture!)} '),
                                          caisse.dateFermeture != null
                                              ? Text(
                                                  'à : ${Utils.dateFull.format((caisse.dateFermeture!))}')
                                              : const Text(
                                                  'Date fermeture: <vide>'),
                                          Text(
                                              'Recette: ${Utils.formatCFA(caisse.recette!)}'),
                                          Text(docId),
                                          Text(caisse.accountId!),
                                        ])),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue),
                                          child: const Text('Fermer',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    )
                                  ]),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5.0),
                          color: Colors.white,
                          child: ListTile(
                            leading: Text(
                                Utils.dateShort.format(caisse.dateOuverture!),
                                style: const TextStyle(
                                    //color: Color(0xFFF3774D),

                                    fontSize: 14)),
                            title: Text(Utils.formatCFA(caisse.recette!),
                                style: const TextStyle(
                                  fontSize: 14,
                                )),
                            trailing: caisse.dateFermeture == null
                                ? const Text('En cours',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue))
                                : Text('Fermée',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade800)),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('No data');
                }
              }),
        )
      ]),
    )));
  }
}
