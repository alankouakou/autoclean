import 'package:autoclean/features/tarification/pages/widgets/tarif_list_widget.dart';
import 'package:flutter/material.dart';

class TarifsPage extends StatelessWidget {
  const TarifsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Center(
              child: Text('Liste des prestations',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold))),
          Expanded(child: TarifListWidget()),
        ],
      ),
    ));
  }
}
