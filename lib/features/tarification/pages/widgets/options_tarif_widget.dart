import 'dart:math';

import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/pages/new_caisse_page.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';
// import 'package:autoclean/features/prestations/services/firestore_service.dart';
import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/tarification/services/tarifs_provider.dart';
//import 'package:autoclean/features/prestations/pages/saisie_prestation.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionTarifWidget extends ConsumerStatefulWidget {
  const OptionTarifWidget(
      {super.key, required this.option, required this.couleur});
  final Option option;
  final Color couleur;

  @override
  ConsumerState<OptionTarifWidget> createState() => _OptionTarifWidgetState();
}

class _OptionTarifWidgetState extends ConsumerState<OptionTarifWidget> {
  final _formKey = GlobalKey<FormState>();
  // final firestore = FiresStoreService();
  late final String? accountId;
  late final String? caisseId;
  late final SharedPreferences sp;

  final _detailsVehiculeController = TextEditingController();

  @override
  void initState() {
    getUserUID();
    super.initState();
  }

  void getUserUID() async {
    final sp = await SharedPreferences.getInstance();
    accountId = sp.getString('firebase_auth_uid');
    //caisseId = sp.getString('caisseId');
  }

  @override
  void dispose() {
    _detailsVehiculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTarrifName = ref.watch(selectedTarifName);
    //final nomTarif = ref.watch(selectedTarifName);
    final caisse = ref.watch(caisseProvider);
    //final caisseIdFuture = ref.watch(caisseFutureProvider);

    return ActionChip(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Text(widget.option.libelle,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: widget.couleur.withOpacity(0.8),
        avatar: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black.withOpacity(0.2),
            child: Text(widget.option.libelle[0],
                style: const TextStyle(color: Colors.white, fontSize: 12))),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                              height: 300,
                              width: double.infinity,
                              child:
                                  Wrap(runSpacing: 15, spacing: 4, children: [
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(currentTarrifName,
                                        style: TextStyle(
                                            color: widget.couleur,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold))),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                        '${widget.option.libelle} : ${Utils.formatCFA(widget.option.prix)}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold))),
                                TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) => value!.isEmpty
                                        ? 'Entrez les détails (marque immatriculation)'
                                        : null,
                                    controller: _detailsVehiculeController,
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 30, right: 30),
                                        hintText:
                                            'Immatriculation, marque vehicule',
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: BorderSide.none),
                                        fillColor: Colors.grey.shade300)),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                              foregroundColor: Colors.white),
                                          child: const Text('Annuler')),
                                      ElevatedButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              var caisseId = await caisse
                                                  .getIdCaisseOuverte(
                                                      userAccountId:
                                                          accountId!);
                                              var p = Prestation(
                                                  id: Random().hashCode,
                                                  libelle:
                                                      '$currentTarrifName - ${widget.option.libelle}',
                                                  prix: widget.option.prix,
                                                  montantRecu:
                                                      widget.option.prix,
                                                  monnaie: 0.0,
                                                  annulee: false,
                                                  datePrestation:
                                                      DateTime.now(),
                                                  detailsVehicule:
                                                      _detailsVehiculeController
                                                          .text,
                                                  caisseId: caisseId,
                                                  accountId: accountId!);
                                              // firestore.addPrestation(p);
                                              ref.read(
                                                  prestationsProvider.notifier)
                                                ..add(p)
                                                ..save();

                                              //met à jour le solde de caisse
                                              /* ref
                                                  .read(caisseNotifierProvider
                                                      .notifier)
                                                  .add(widget.option.prix); */
                                              _detailsVehiculeController
                                                  .clear();
                                              Navigator.pop(context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: widget.couleur,
                                              foregroundColor: Colors.white),
                                          child: const Text('Valider'))
                                    ])
                              ])),
                        )),
                  ));
        });
  }
}
