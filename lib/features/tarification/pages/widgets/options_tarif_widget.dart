import 'dart:math';

import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/caisse_service.dart';
import 'package:autoclean/features/tarification/models/tarifs.dart';
import 'package:autoclean/features/tarification/services/tarifs_provider.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../laveurs/models/laveur.dart';
import '../../../laveurs/pages/widgets/chips_laveurs.dart';
import '../../../laveurs/services/laveur_notifier.dart';

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
  late final String? accountId;
  late final String? caisseId;
  late final SharedPreferences sp;

  final _detailsVehiculeController = TextEditingController();
  final _coutPrestationController = TextEditingController();

  @override
  void initState() {
    getUserUID();
    super.initState();
  }

  void getUserUID() async {
    final sp = await SharedPreferences.getInstance();
    accountId = sp.getString('firebase_auth_uid');
  }

  @override
  void dispose() {
    _detailsVehiculeController.dispose();
    _coutPrestationController.dispose();
    super.dispose();
  }

  String? notEmpty(String? val) {
    return val == null || val.isEmpty ? 'Champ obligatoire' : null;
  }

  String? minValue(String? val) {
    final myVal = double.tryParse(val!);
    if (myVal == null) {
      return 'Entrez le prix';
    } else if (myVal < widget.option.prix) {
      return 'Prix minimum ${widget.option.prix} FCFA';
    }

    return null;
  }

  Widget customTextField(
      {required String hintText,
      required TextEditingController textController,
      required String? Function(String? val) validator}) {
    return TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.number,
        validator: validator,
        controller: textController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            hintText: hintText,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            fillColor: Colors.grey.shade300));
  }

  @override
  Widget build(BuildContext context) {
    final currentTarrifName = ref.watch(selectedTarifName);
    List<Laveur> laveurs = <Laveur>[];
    final asyncLaveurs = ref.watch(laveurProvider);
    final laveur = ref.watch(selectedLaveur);
    final caisse = ref.watch(caisseProvider);
    asyncLaveurs.when(
        data: (data) {
          laveurs = data;
        },
        error: (e, s) {},
        loading: () {});

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
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                              height: 400,
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
                                widget.option.fixedPrice == true
                                    ? Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                            '${widget.option.libelle} : ${Utils.formatCFA(widget.option.prix)}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)))
                                    : Container(
                                        alignment: Alignment.center,
                                        child: Text(widget.option.libelle,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold))),
                                widget.option.fixedPrice == true
                                    ? Container()
                                    : customTextField(
                                        hintText:
                                            '${Utils.formatCFA(widget.option.prix)} prix minimum  ',
                                        textController:
                                            _coutPrestationController,
                                        validator: minValue),
                                TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) => value!.isEmpty
                                        ? 'Entrez les détails (marque, immatriculation, etc.)'
                                        : null,
                                    controller: _detailsVehiculeController,
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 30, right: 30),
                                        hintText: 'Details',
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: BorderSide.none),
                                        fillColor: Colors.grey.shade300)),
                                SizedBox(
                                    height: 50,
                                    width: 400,
                                    child: LaveurChips(laveurs: laveurs)),
                                const SizedBox(height: 10),
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
                                                  prix: widget.option
                                                              .fixedPrice ==
                                                          true
                                                      ? widget.option.prix
                                                      : double.parse(
                                                          _coutPrestationController
                                                              .text),
                                                  montantRecu: widget.option
                                                              .fixedPrice ==
                                                          true
                                                      ? widget.option.prix
                                                      : double.parse(
                                                          _coutPrestationController
                                                              .text),
                                                  monnaie: 0.0,
                                                  annulee: false,
                                                  datePrestation:
                                                      DateTime.now(),
                                                  detailsVehicule:
                                                      _detailsVehiculeController
                                                          .text,
                                                  caisseId: caisseId!,
                                                  laveur: ref
                                                      .read(selectedLaveur
                                                          .notifier)
                                                      .state,
                                                  accountId: accountId!);
                                              if (ref
                                                      .read(selectedLaveur
                                                          .notifier)
                                                      .state ==
                                                  '') {
                                                Utils.showErrorMessage(
                                                    message:
                                                        'Selectionnez un laveur svp!');
                                                ref.invalidate(selectedLaveur);
                                              } else {
                                                ref.read(prestationsProvider
                                                    .notifier)
                                                  ..add(p)
                                                  ..save();
                                                print(
                                                    'Storing laveur ID: $laveur');
                                                _detailsVehiculeController
                                                    .clear();
                                                ref.invalidate(selectedLaveur);
                                                Navigator.pop(context);
                                              }
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
