import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/mouvement_caisse.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';

import 'package:autoclean/features/prestations/services/mvt_caisse_service.dart';
import 'package:autoclean/features/printing/services/printing_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PointCaisse extends ConsumerWidget {
  const PointCaisse(
      {required this.dateOuverture,
      required this.nombrePrestations,
      required this.montantTotalPrestations,
      required this.listePrestations,
      super.key});
  final DateTime dateOuverture;
  final int nombrePrestations;
  final double montantTotalPrestations;
  final List<Prestation> listePrestations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caisseCourante = ref.watch(caisseNotifierProvider);
    final mvtCaisses = ref.watch(mvtCaisseNotifierProvider);
    final authService = ref.watch(authProvider);
    final currentCaisseId = ref.watch(caisseIdProvider);
    final DateTime dateFermeture = DateTime.now();
    final halfScreenwidth = (MediaQuery.of(context).size.width - 20) / 2;
    double totalMvtsEntree = 0.0;
    double totalMvtsSortie = 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: caisseCourante.when(
                  data: (data) => Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                            'Point de caisse ${Utils.dateShort.format(data.dateOuverture!)}',
                            style: const TextStyle(
                                color: Color(0xFFF3774D),
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        Center(
                            child: IconButton(
                                icon: const Icon(Icons.print,
                                    color: Color(0xFFF3774D)),
                                onPressed: () async {
                                  print(
                                      '# prestations filtrées: ${listePrestations.length}');

                                  final mvtsCaisse = await ref
                                      .read(mvtCaisseNotifierProvider.notifier)
                                      .fetchMvts(currentCaisseId);
                                  PrintingService.printDailyReport(
                                      data, mvtsCaisse, listePrestations);
                                })),
                        const SizedBox(height: 20),
                        openCloseHoursWidget(
                            dateOuverture, dateFermeture, halfScreenwidth - 60),
                        const SizedBox(height: 30),
                        _lineItemWidget(
                            label: "Nbre Prestations",
                            content: '$nombrePrestations',
                            size: halfScreenwidth),
                        _lineItemWidget(
                            label: "Mt Prestations",
                            content: Utils.formatCFA(montantTotalPrestations),
                            size: halfScreenwidth),
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
                              return totalEntreesSortiesWidget(totalMvtsEntree,
                                  totalMvtsSortie, halfScreenwidth);
                            },
                            error: (e, s) => Container(),
                            loading: () => Container()),
                        _lineItemWidget(
                            label: "Solde final",
                            content: Utils.formatCFA(montantTotalPrestations +
                                totalMvtsEntree -
                                totalMvtsSortie),
                            size: halfScreenwidth - 50,
                            fontSize: 18,
                            color: Colors.blue),
                        const SizedBox(height: 10.0),
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
                                                  BorderRadius.circular(10.0)),
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
                                                    color: Colors.green),
                                            title: Text(
                                                '${Utils.timeShort.format(data[index].dateMaj)} - ${data[index].details}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                            trailing: Text(
                                              Utils.formatCFA(
                                                  data[index].montant),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                error: (e, s) {
                                  print(s.toString());
                                  return Container(child: Text(e.toString()));
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()))),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white),
                          child: SizedBox(
                            height: 100,
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
                                        //update caisse
                                        final newData = data.copyWith(
                                          dateFermeture: dateFermeture,
                                          recette: montantTotalPrestations +
                                              totalMvtsEntree -
                                              totalMvtsSortie,
                                        );
                                        //maj Backend
                                        ref
                                            .read(
                                                caisseNotifierProvider.notifier)
                                            .maj(newData, currentCaisseId);

                                        Utils.showInfoMessage(
                                            message:
                                                "Caisse $currentCaisseId updated successfully!");

                                        authService.signOut();
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
                                      child: const Text('Valider',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)))
                                ]),
                          ),
                        )
                      ]),
                  error: (e, s) => const Text('Error '),
                  loading: () => const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator())),
                )),
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
}
