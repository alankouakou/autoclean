import 'package:flutter/material.dart';

class InfosCaisse extends StatelessWidget {
  const InfosCaisse({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Center(
          child: Text('Ecran principal caisse',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold))),
    ));
  }
}
