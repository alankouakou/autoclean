import 'package:autoclean/core/utils.dart';

import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/prestations/services/histo_mvt_caisse_provider.dart';
import 'package:autoclean/features/prestations/services/histo_prestation_provider.dart';

import 'package:autoclean/features/prestations/services/mvt_caisse_service.dart';
import 'package:autoclean/features/printing/services/printing_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoCaisse extends ConsumerWidget {
  const HistoCaisse({required this.caisseId, super.key});
  final String caisseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Histo Caisse - Caisse ID: $caisseId');
    //maj caisse ID pour actualiser histoPrestationsProvider

    final caisseCourante =
        ref.watch(caisseNotifierProvider.notifier).fetchById(caisseId);
    final prestations = ref.watch(histoPrestationsProvider);
    final mvtsCaisse = ref.watch(histoMvtsCaisseProvider);
    print('Histo Caisse prestation - prm Caisse ID: $caisseId');

    final listePrestations = prestations;

    final halfScreenwidth = (MediaQuery.of(context).size.width - 20) / 2;
    double totalMvtsEntree = 0.0;
    double totalMvtsSortie = 0.0;
    // int nombrePrestations = listePrestations.length;
    // double montantTotalPrestations =
    //     listePrestations.fold(0.0, (acc, elt) => acc + elt.prix);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: FutureBuilder(
                      future: caisseCourante,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            snapshot.hasData) {
                          final caisse = snapshot.data!;
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                    'Point de caisse ${Utils.dateShort.format(caisse.dateOuverture!)}',
                                    style: const TextStyle(
                                        color: Color(0xFFF3774D),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                Text('CaisseID: $caisseId'),
                                Center(
                                    child: IconButton(
                                        icon: const Icon(Icons.print,
                                            color: Color(0xFFF3774D)),
                                        onPressed: () {})),
                                const SizedBox(height: 20),
                                openCloseHoursWidget(
                                    caisse.dateOuverture!,
                                    caisse.dateFermeture ?? DateTime.now(),
                                    halfScreenwidth - 60),
                                const SizedBox(height: 5),
                                _lineItemWidget(
                                    label: "Nbre Prestations",
                                    content: '',
                                    size: halfScreenwidth),
                                _lineItemWidget(
                                    label: "Mt Prestations",
                                    content: '',
                                    size: halfScreenwidth),
                                _lineItemWidget(
                                    label: "Solde final",
                                    content: '',
                                    size: halfScreenwidth - 50,
                                    fontSize: 18,
                                    color: Colors.blue),
                                const SizedBox(height: 10.0),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      //borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.grey.shade100),
                                  child: const Text('Prestations',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]);
                        } else {
                          return Column(
                            children: [
                              const Text('Pas de donnée'),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white),
                                child: const Text('Fermer'),
                              )
                            ],
                          );
                        }
                      },
                    )),
              ),
              mvtsCaisse.when(
                  data: (data) => Expanded(
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final mvtCaisse = data[index];
                            final couleur = mvtCaisse.typeMouvement == 'Entree'
                                ? Colors.green
                                : Colors.red;
                            final iconData = mvtCaisse.typeMouvement == 'Entree'
                                ? Icons.arrow_forward
                                : Icons.arrow_back;
                            return Container(
                                padding: const EdgeInsets.all(5.0),
                                child: ListTile(
                                    leading: Icon(iconData, color: couleur),
                                    title: Text(mvtCaisse.details,
                                        style: TextStyle(color: couleur)),
                                    trailing: Text(
                                        Utils.formatCFA(mvtCaisse.montant),
                                        style: TextStyle(color: couleur))));
                          })),
                  error: (err, stack) =>
                      const Center(child: Text('Une eerreur est survenue!')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator())),
              prestations.when(
                data: (listPrestations) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: listPrestations.length,
                        itemBuilder: (context, index) {
                          final prestation = listPrestations[index];
                          return GestureDetector(
                            onLongPress: () {
                              infosPrestation(context, prestation);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              color: Colors.white,
                              child: ListTile(
                                  leading: Text(Utils.dateShort
                                      .format(prestation.datePrestation)),
                                  title: Text(prestation.libelle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14)),
                                  trailing:
                                      Text(Utils.formatCFA(prestation.prix))),
                            ),
                          );
                        }),
                  );
                },
                error: (error, stackTrace) {
                  return Text(error.toString());
                },
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white),
                child: const Text('Fermer'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _lineItemWidget(
      {required String label,
      required String content,
      required size,
      double? fontSize,
      Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(color: Colors.white),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              width: size,
              child: Text("$label :",
                  style: TextStyle(
                      color: color ?? Colors.black,
                      fontSize: fontSize ?? 14,
                      fontWeight: FontWeight.bold))),
          Expanded(
              child: Container(
            alignment: Alignment.centerRight,
            child: Text("$content ",
                style: TextStyle(
                    fontSize: fontSize ?? 14,
                    color: color ?? Colors.black,
                    fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _oneLineItem({required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(color: Colors.white),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            child: Text("$content ",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _oneLineLabel({required String content}) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      decoration: const BoxDecoration(color: Colors.white),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            child: Text("$content ",
                style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget openCloseHoursWidget(
      DateTime dateOuverture, DateTime dateFermeture, double containerWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        SizedBox(
            width: containerWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ouvert à:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
                Text(Utils.dateShort.format(dateOuverture),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(Utils.timeFull.format(dateOuverture),
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold))
              ],
            )),
        Container(color: Colors.grey.withOpacity(0.5), height: 50, width: 2),
        SizedBox(
            width: containerWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fermé à:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF3774D))),
                Text(Utils.dateShort.format(dateFermeture),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(Utils.timeFull.format(dateFermeture),
                    style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFF3774D),
                        fontWeight: FontWeight.bold))
              ],
            )),
      ]),
    );
  }

  Widget totalEntreesSortiesWidget(
      double totalEntrees, double totalSorties, double width) {
    return Column(children: [
      _lineItemWidget(
          label: "Entrées caisse",
          color: Colors.teal,
          content: Utils.formatCFA(totalEntrees),
          size: width),
      _lineItemWidget(
          label: "Sorties caisse",
          color: Colors.red,
          content: Utils.formatCFA(totalSorties),
          size: width)
    ]);
  }

  Widget infosDialog(MouvementCaisse mvtCaisse, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mvtCaisse.details,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Type mouvement: ${mvtCaisse.typeMouvement}'),
          Text('Montant: ${Utils.formatCFA(mvtCaisse.montant)}'),
          Text(Utils.dateFull.format(mvtCaisse.dateMaj)),
          const SizedBox(height: 20.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0))),
                child: const Text('OK', style: TextStyle(color: Colors.white)))
          ]),
          const SizedBox(height: 40)
        ],
      ),
    );
  }

  void infosPrestation(BuildContext context, Prestation prestation) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: 350,
              //height: 300,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(prestation.detailsVehicule,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(prestation.libelle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(Utils.formatCFA(prestation.prix),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(Utils.dateFull.format(prestation.datePrestation)),
                    const SizedBox(height: 10),
                    Text(prestation.caisseId!),
                    Text(prestation.accountId),
                    const SizedBox(height: 30),
                    IconButton(
                        onPressed: () {
                          PrintingService.printReceipt(prestation);
                        },
                        icon: const Icon(
                            size: 30.0, Icons.print, color: Color(0xFFF3774D))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text('Fermer',
                            style: TextStyle(color: Colors.white))),
                    const SizedBox(
                      height: 10,
                    )
                  ]),
            ));
  }
}


/*

BOUTS DE CODE A RECUPERER

mvtCaisses.when(
                                data: (values) {
                                  totalMvtsEntree = values
                                      .where((element) =>
                                          element.typeMouvement == 'Entree')
                                      .fold(0.0, (acc, b) => acc + b.montant);
                                  totalMvtsSortie = values
                                      .where((element) =>
                                          element.typeMouvement == 'Sortie')
                                      .fold(0.0, (acc, b) => acc + b.montant);
                                  return totalEntreesSortiesWidget(
                                      totalMvtsEntree,
                                      totalMvtsSortie,
                                      halfScreenwidth);
                                },
                                error: (e, s) => Container(),
                                loading: () => Container()),
*/

/*

                           Expanded(
                                child: mvtCaisses.when(
                                    data: (data) {
                                      print('Nbre de mvts: ${data.length}');
                                      return ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onLongPress: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return infosDialog(
                                                      data[index], context);
                                                },
                                              );
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                margin: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: ListTile(
                                                    leading: data[index]
                                                                .typeMouvement ==
                                                            "Sortie"
                                                        ? const Icon(Icons.arrow_back,
                                                            color: Colors.red)
                                                        : const Icon(
                                                            Icons.arrow_forward,
                                                            color:
                                                                Colors.green),
                                                    title: Text(
                                                        '${Utils.timeShort.format(data[index].dateMaj)} - ${data[index].details}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 14)),
                                                    trailing: Text(Utils.formatCFA(data[index].montant), style: const TextStyle(fontSize: 14)))),
                                          );
                                        },
                                      );
                                    },
                                    error: (e, s) {
                                      print(s.toString());
                                      return Container(
                                          child: Text(e.toString()));
                                    },
                                    loading: () => const Center(
                                        child: CircularProgressIndicator()))),
 */