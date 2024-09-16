import 'dart:io';
import 'dart:typed_data';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils.dart';
import '../../prestations/models/caisse.dart';
import '../../prestations/models/mouvement_caisse.dart';

class PrintingService {
//generate Receipt
  static Future<Uint8List> generateReceipt(Prestation p) {
    print('pdf generation starts!');
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context content) {
        return pw.Center(
            child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(Utils.dateFull.format(p.datePrestation),
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Reçu lavage'),
              pw.SizedBox(height: 10),
              pw.Text(p.detailsVehicule,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              //pw.SizedBox(height: 10),
              pw.Text('Prestation: ${p.libelle}',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Montant: ${Utils.formatCFA(p.prix)}',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text('Caisse: ${p.caisseId ?? ''}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('User: ${p.accountId}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 30),
            ]));
      },
      pageFormat: PdfPageFormat.roll80,
    ));
    print('pdf generation ends!');
    return pdf.save();
  }

  // Generate Daily report
  static Future<Uint8List> generateDailyReport(Caisse caisse,
      List<MouvementCaisse> mvts, List<Prestation> prestations) async {
    final double totalMvtsEntree = mvts
        .where((elt) => elt.typeMouvement == 'Entree')
        .fold(0.0, (cumul, mvt) {
      return cumul + mvt.montant;
    });
    final double totalMvtsSortie = mvts
        .where((elt) => elt.typeMouvement == 'Sortie')
        .fold(0.0, (cumul, mvt) {
      return cumul + mvt.montant;
    });

    final totalPrestations = prestations.length;

    final double totalMtPrestations =
        prestations.fold(0.0, (cumul, p) => cumul + p.prix);

    final soldeFinal = totalMvtsEntree - totalMvtsSortie + totalMtPrestations;

    // Tableau recapitulatif
    final headersRecap = ["SECTION", "TOTAL"];
    final List<List<dynamic>> tabRecap = [];
    tabRecap.add(['Nb Total Mouvements caisse', '${mvts.length}']);
    tabRecap.add(['Nb Total Véhicules', totalPrestations.toString()]);
    tabRecap.add(['Montant Total Entrées', Utils.formatCFA(totalMvtsEntree)]);
    tabRecap.add(
        ['Montant Total Sorties', '- ${Utils.formatCFA(totalMvtsSortie)}']);
    tabRecap.add(
        ['Montant Total Prestations', Utils.formatCFA(totalMtPrestations)]);
    tabRecap.add(['Solde final', Utils.formatCFA(soldeFinal)]);

    final pdf = pw.Document();

    final logoEntreprise =
        (await rootBundle.load('assets/icon/icon.png')).buffer.asUint8List();
    final headersMvtCaisse = [
      'Entrée/Sortie',
      'Date mouvement',
      'Description',
      'Montant'
    ];
    final mvtsCaisse = mvts
        .map((item) => [
              item.typeMouvement,
              Utils.dateFull.format(item.dateMaj),
              item.details,
              item.typeMouvement == 'Sortie'
                  ? pw.Text('- ${Utils.formatCFA(item.montant)}',
                      style: const pw.TextStyle(color: PdfColors.red))
                  : pw.Text(Utils.formatCFA(item.montant),
                      style: const pw.TextStyle(color: PdfColors.teal))
            ])
        .toList();

    final headersPrestations = [
      'Date',
      'Description',
      'Véhicule',
      'Montant prestation'
    ];
    final mvtPrestations = prestations
        .map((p) => [
              Utils.dateFull.format(p.datePrestation),
              p.libelle,
              p.detailsVehicule,
              Utils.formatCFA(p.prix)
            ])
        .toList();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Image(width: 80, height: 80, pw.MemoryImage(logoEntreprise)),
            pw.SizedBox(height: 30.0),
            pw.Center(
                child: pw.Text(
                    'POINT DE CAISSE du ${Utils.dateShort.format(caisse.dateOuverture!)}',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.Text('Overt à: ${Utils.dateFull.format(caisse.dateOuverture!)}'),
            pw.Text('User: ${caisse.caissier}'),
            pw.SizedBox(height: 30.0),
            pw.Center(
                child: pw.Text('RECAPITULATIF',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
                headers: headersRecap,
                data: tabRecap,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                }),
          ]);
        }));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text('MOUVEMENTS DE CAISSE',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 30.0),
            pw.TableHelper.fromTextArray(
                headers: headersMvtCaisse,
                data: mvtsCaisse,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight
                }),
            //pw.TableHelper.fromTextArray(headers:,data: dataPrestations)
          ]);
        }));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context ctx) {
          return pw.Column(children: [
            pw.Text('PRESTATIONS - LAVAGE',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
                headers: headersPrestations,
                data: mvtPrestations,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight
                })
          ]);
        }));
    print('pdf daily report ends!');
    return pdf.save();
  }

  // save Pdf File
  static Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = await getApplicationCacheDirectory();

    late final String filePath;
    if (Platform.isAndroid) {
      filePath = '${cacheDir.path}/$fileName.pdf';
    } else {
      filePath = '${dir.path}/$fileName.pdf';
    }

    File file = File(filePath);
    await file.writeAsBytes(byteList);
    OpenFile.open(filePath);
  }

  //print Receipt
  static Future printReceipt(Prestation p) async {
    final myPdf = await generateReceipt(p);
    savePdfFile('recu', myPdf);
  }

  // print Daily report
  static printDailyReport(Caisse caisse, List<MouvementCaisse> mvts,
      List<Prestation> prestations) async {
    final dailyReport = await generateDailyReport(caisse, mvts, prestations);
    savePdfFile('dailyReport', dailyReport);
  }
}
