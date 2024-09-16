import 'dart:io';

import 'package:autoclean/features/printing/models/recu.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';

import '../../../core/utils.dart';

const TAUX_TVA = 18;

class PdfInvoiceApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    final file = File('$dir/$name');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return file;
  }

  static openFile(String path) {
    OpenFile.open(path);
  }

  static Widget buildSimpleFooter(context) {
    return Column(
      children: [
        Divider(),
        Container(
            child: Text('Page ${context.pageNumber} de ${context.pagesCount}'),
            alignment: Alignment.centerRight),
      ],
    );
  }

  static Widget buildTitle(String title) {
    return Container(
        padding: const EdgeInsets.only(left: 20.0, bottom: 30.0),
        child: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: PdfColors.deepOrange)));
  }

  static Widget buildSimpleRow(String caption, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(caption,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.grey700))),
        Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.grey900))),
      ],
    );
  }

  static Widget buildEnteteFacture(Recu recu, Uint8List logo) {
    // initializeDateFormatting('fr_FR');
    return Row(children: [
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(width: 80, height: 80, MemoryImage(logo)),
            Text('Entete ligne 1', style: const TextStyle(fontSize: 8)),
            Text('Entete ligne 2', style: const TextStyle(fontSize: 8)),
            SizedBox(height: 25 * PdfPageFormat.mm),
          ]),
      Expanded(child: Container()),
      Container(
        width: 200,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2 * PdfPageFormat.cm,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildJustifyRow(
                          caption: 'Facture ',
                          value: '',
                        ),
                        buildJustifyRow(
                          caption: 'Date facturat° :',
                          value: Utils.dateShort.format(recu.datePrestation),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                  height: 35 * PdfPageFormat.mm,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildJustifyRow(
                          caption: 'Client :',
                          value: recu.vehicule,
                        ),
                        buildJustifyRow(
                          caption: 'Contact :',
                          value: recu.contact,
                        ),
                      ])),
            ]),
      ),
    ]);
  }

  static Widget buildJustifyRow(
      {required String caption,
      required String value,
      bool bold = true,
      bool money = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(caption,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : null,
                    color: PdfColors.grey700))),
        Expanded(child: Container()),
        Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Text(money ? Utils.formatCFA(double.parse(value)) : value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : null,
                    color: PdfColors.grey900))),
      ],
    );
  }

  static Widget generateRecu(Recu recu, Uint8List logo) {
    // initializeDateFormatting('fr_FR');
    return Row(children: [
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(width: 80, height: 80, MemoryImage(logo)),
            Text('Titre (Reçu client)', style: const TextStyle(fontSize: 8)),
            Text('Date de la prestation', style: const TextStyle(fontSize: 8)),
            Text('Contact du lavage', style: const TextStyle(fontSize: 8)),
            Text('details Vehicule', style: const TextStyle(fontSize: 8)),
            Text('details Rrestation', style: const TextStyle(fontSize: 8)),
            Text('Montant de la prestation',
                style: const TextStyle(fontSize: 8)),
            SizedBox(height: 25 * PdfPageFormat.mm),
          ]),
      Expanded(child: Container()),
      Container(
        width: 200,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2 * PdfPageFormat.cm,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildJustifyRow(
                          caption: 'Facture ',
                          value: '',
                        ),
                        buildJustifyRow(
                          caption: 'Echeance :',
                          value: '',
                        ),
                      ]),
                ),
              ),
              SizedBox(
                  height: 35 * PdfPageFormat.mm,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildJustifyRow(
                          caption: 'Client :',
                          value: '',
                        ),
                        buildJustifyRow(
                          caption: 'Contact :',
                          value: '',
                        ),
                      ])),
            ]),
      ),
    ]);
  }

  static Widget buildDetailsFacture(Recu recu) {
    final headers = [
      'Description',
      'Date',
      'Qté',
      'P. Unitaire',
      'Montant TTC'
    ];
    final List<List<dynamic>> data = [];

    return TableHelper.fromTextArray(
        data: data,
        headers: headers,
        border: null,
        headerStyle:
            TextStyle(fontWeight: FontWeight.bold, color: PdfColors.white),
        headerDecoration: const BoxDecoration(color: PdfColors.orange800),
        cellHeight: 25,
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerLeft,
          2: Alignment.centerRight,
          3: Alignment.centerRight,
          4: Alignment.centerRight
        });
  }

  static Widget buildFactureFooter(Recu recu) {
    return Column(
      children: [
        Divider(),
        Container(
            child: Text('pied de page', style: const TextStyle(fontSize: 8)),
            alignment: Alignment.centerRight),
      ],
    );
  }

  static Future<File> generateReceipt(Recu recu) async {
    final _logoEntreprise =
        (await rootBundle.load('assets/icon/icon.png')).buffer.asUint8List();
    final File file;
    final pdf = Document(author: 'CleanAuto', title: 'Reçu Client');

    pdf.addPage(
      MultiPage(
        build: (context) => <Widget>[
          buildEnteteFacture(recu, _logoEntreprise),
          buildDetailsFacture(recu),
          SizedBox(height: 100),
        ],
        footer: (context) => buildFactureFooter(recu),
      ),
    );

    file = await saveDocument(name: 'recu.pdf', pdf: pdf);
    return file;
  }
}
