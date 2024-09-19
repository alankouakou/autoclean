import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';

import 'package:autoclean/features/prestations/services/caisse_service.dart';

import 'package:autoclean/main_page.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewCaissePage extends ConsumerWidget {
  const NewCaissePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caisseRepository = CaisseService(
      authService: ref.watch(authProvider),
    );
    final dateOuverture = DateTime.now();
    final libelle = 'Journée du ${Utils.dateShort.format(dateOuverture)}';
    TextEditingController siController = TextEditingController();
    final _auth = ref.watch(authProvider);

    return Scaffold(
        appBar: AppBar(title: const Text('Ouverture de la caisse')),
        body: Column(children: [
          const Text('Ouverture de la caisse',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal)),
          Text(libelle,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal)),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: TextFormField(
              controller: siController,
              keyboardType: TextInputType.number,
              validator: (value) => siController.text.isEmpty
                  ? 'Renseignez le solde initial!'
                  : null,
              //initialValue: '0',
              // Le login doit être unique
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                  hintText: 'Entrez le solde initial (Fond de caisse)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none),
                  fillColor: Colors.black12,
                  filled: true),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Créer caisse journée
              if (siController.text.isNotEmpty) {
                final caisse = Caisse(
                    libelle: libelle,
                    dateOuverture: DateTime.now(),
                    accountId: _auth.currentUser!.uid,
                    soldeInitial: double.parse(siController.text),
                    caissier: _auth.currentUser!.email ?? '');
                final caisseRefId = await caisseRepository.add(caisse);
                final SharedPreferences sp =
                    await SharedPreferences.getInstance();
                final varEmail = _auth.currentUser!.email;
                sp.setString('caisseId_$varEmail', caisseRefId);

                Utils.showInfoMessage(message: 'Caisse Id:$caisseRefId');
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false);
              } else {
                Utils.showErrorMessage(message: 'Renseignez le solde initial!');
              }
            },
            style: ElevatedButton.styleFrom(
                fixedSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0))),
            child:
                const Text('Ouvrir la caisse', style: TextStyle(fontSize: 16)),
          )
        ]));
  }
}
