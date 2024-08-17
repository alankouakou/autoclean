import 'package:flutter/material.dart';

class CaissePage extends StatelessWidget {
  const CaissePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30),
      child: Column(children: [
        const Text('Consultation recettes mensuelles',
            style: TextStyle(
                fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _inputText('Selectionnez le mois', TextInputType.text),
        const SizedBox(height: 20),
        _btn(context: context, caption: 'Consulter', couleur: Colors.teal),
      ]),
    )));
  }

  Widget _inputText(String hint, TextInputType kbt) {
    return TextField(
        keyboardType: kbt,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            fillColor: Colors.grey.shade300));
  }

  Widget _btn(
      {required BuildContext context,
      required String caption,
      required Color couleur}) {
    return ElevatedButton(
        onPressed: () {
          //Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            backgroundColor: couleur,
            foregroundColor: Colors.white),
        child: Text(caption));
  }
}
