import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/laveurs/models/laveur.dart';
import 'package:autoclean/features/laveurs/services/laveur_notifier.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLaveur extends ConsumerStatefulWidget {
  const EditLaveur(
      {super.key,
      required this.laveurId,
      required this.nom,
      required this.contact});
  final String laveurId;
  final String nom;
  final String contact;

  @override
  ConsumerState<EditLaveur> createState() => _EditLaveurState();
}

class _EditLaveurState extends ConsumerState<EditLaveur> {
  TextEditingController contactController = TextEditingController();
  TextEditingController nomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final accountId = auth.currentUser!.uid;

    contactController.text = widget.contact;
    nomController.text = widget.nom;

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
                              Text('Mise à jour laveur ${widget.laveurId}',
                                  style: const TextStyle(
                                      color: Color(0xFFF3774D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Text('Compte: ${widget.laveurId}',
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
                                    onPressed: () async {
                                      final laveur = Laveur(
                                        id: widget.laveurId,
                                        dateCreated: DateTime.now(),
                                        nom: nomController.text,
                                        contact: contactController.text,
                                        actif: true,
                                        accountId: accountId,
                                      );
                                      ref
                                          .read(laveurProvider.notifier)
                                          .maj(widget.laveurId, laveur);
                                      ref.invalidate(laveurProvider);

                                      nomController.clear();
                                      contactController.clear();

                                      Utils.showSuccessMessage(
                                          message: 'Laveur mis à jour!');
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
