import 'package:flutter/material.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Center(
          child: Text('Clients Page',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold))),
    ));
  }
}
