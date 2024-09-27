import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/laveurs/models/laveur.dart';
import 'package:autoclean/features/laveurs/services/laveur_notifier.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AjoutLaveur extends ConsumerStatefulWidget {
  const AjoutLaveur({super.key});

  @override
  ConsumerState<AjoutLaveur> createState() => _AjoutLaveurState();
}

class _AjoutLaveurState extends ConsumerState<AjoutLaveur> {
  TextEditingController contactController = TextEditingController();
  TextEditingController nomController = TextEditingController();

  @override
  void dispose() {
    contactController.dispose();
    nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final accountId = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            children: [
                              const Text('Nouveau laveur',
                                  style: TextStyle(
                                      color: Color(0xFFF3774D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Text('Compte: $accountId',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF3774D))),
                              const SizedBox(height: 20),
                            ],
                          )),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nomController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'Nom ',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: contactController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'Contact',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: SizedBox(
                          height: 90,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: const BorderSide(
                                                width: 1.0,
                                                color: Color(0xFFF3774D))),
                                        elevation: 0,
                                        backgroundColor: Colors.white),
                                    child: const Text('Annuler',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFF3774D),
                                            fontWeight: FontWeight.bold))),
                                const SizedBox(width: 30),
                                ElevatedButton(
                                    onPressed: () {
                                      final laveur = Laveur(
                                        id: '',
                                        dateCreated: DateTime.now(),
                                        nom: nomController.text,
                                        contact: contactController.text,
                                        actif: true,
                                        accountId: accountId,
                                      );
                                      ref
                                          .read(laveurProvider.notifier)
                                          .add(laveur);
                                      ref.invalidate(laveurProvider);

                                      nomController.clear();
                                      contactController.clear();

                                      Utils.showSuccessMessage(
                                          message: 'Laveur enregistré!');
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: const BorderSide(
                                                width: 1.0,
                                                color: Colors.teal)),
                                        elevation: 0,
                                        backgroundColor: Colors.teal),
                                    child: const Text('Enregistrer',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)))
                              ]),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
