import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final df = DateFormat('HH:mm:ss');
final dfDate = DateFormat('dd/MM/yyyy');
final dfFull = DateFormat('dd/MM/yyyy HH:mm:ss');

class CaissePage extends StatefulWidget {
  const CaissePage({super.key});

  @override
  State<CaissePage> createState() => _CaissePageState();
}

class _CaissePageState extends State<CaissePage> {
  late final SharedPreferences sp;
  String accountId = '';

  void getUserUID() async {
    sp = await SharedPreferences.getInstance();
    accountId = sp.getString('firebase_auth_uid')!;
    print('--Inside getUserUID-- $accountId');
  }

  @override
  void initState() {
    getUserUID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    print('Inside build method - accountId : $accountId');
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 5, right: 5),
      child: Column(children: [
        const Text('Historique',
            style: TextStyle(
                fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getPrestations(),
              builder: (context, snapshot) {
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
                                dfDate.format(prestation.datePrestation),
                                style: const TextStyle(
                                    color: Color(0xFFF3774D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            title: Text(prestation.detailsVehicule,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),

/*                             trailing: Column(
                              children: [
                                Text(formatCFA(prestation.prix),
                                    style: const TextStyle(fontSize: 14))
                              ],
                            ), */
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

  Widget _inputText(String hint, TextInputType kbt) {
    return TextField(
        keyboardType: kbt,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            fillColor: Colors.grey.shade300));
  }

  Widget _btn(
      {required BuildContext context,
      required String caption,
      required Color couleur}) {
    return ElevatedButton(
        onPressed: () {
          //Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            backgroundColor: couleur,
            foregroundColor: Colors.white),
        child: Text(caption));
  }
}
