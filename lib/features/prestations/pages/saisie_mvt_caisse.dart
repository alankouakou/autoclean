import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';
import 'package:autoclean/features/prestations/services/mvt_caisse_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaisieMvtCaisse extends ConsumerStatefulWidget {
  const SaisieMvtCaisse({super.key});

  @override
  ConsumerState<SaisieMvtCaisse> createState() => _SaisieMvtCaisseState();
}

List<String> options = ["Sortie", "Entree"];

class _SaisieMvtCaisseState extends ConsumerState<SaisieMvtCaisse> {
  String typeMouvement = options[0];
  TextEditingController amountController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final idCaisse = ref.watch(caisseIdProvider);
    final mvtCaisseNotifier = ref.watch(mvtCaisseNotifierProvider);
    final dateDuJour = DateTime.now();

    print('Build saisie_mvt_caisse, caisseIdProvider value: $idCaisse');

    final caisseMgr = ref.watch(caisseNotifierProvider);
    double largeurComposant = (MediaQuery.of(context).size.width - 50) / 2;
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
                              Text(
                                  'Saisie caisse - ${Utils.dateShort.format(dateDuJour)}',
                                  style: const TextStyle(
                                      color: Color(0xFFF3774D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Text('Caisse Id: $idCaisse',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF3774D))),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: SizedBox(
                                  width: largeurComposant,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          width: largeurComposant,
                                          child: RadioListTile(
                                            title: Text(options[0]),
                                            value: options[0],
                                            groupValue: typeMouvement,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  typeMouvement = value!;
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: largeurComposant,
                                          child: RadioListTile(
                                            title: Text(options[1]),
                                            value: options[1],
                                            groupValue: typeMouvement,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  typeMouvement = value!;
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 20),
                      TextField(
                        controller: detailsController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'Description...',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'Montant',
                          suffixText: 'FCFA',
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
                                      final mvtCaisse = MouvementCaisse(
                                          caisseId: idCaisse,
                                          dateMaj: DateTime.now(),
                                          details: detailsController.text,
                                          montant: double.parse(
                                              amountController.text),
                                          typeMouvement: typeMouvement);
                                      ref
                                          .read(mvtCaisseNotifierProvider
                                              .notifier)
                                          .addMvt(mvtCaisse);
                                      //Rafraichit le provider
                                      ref.invalidate(mvtCaisseNotifierProvider);
                                      detailsController.clear();
                                      amountController.clear();

                                      Utils.showSuccessMessage(
                                          message:
                                              'Mouvement caisse enregistré!');
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
