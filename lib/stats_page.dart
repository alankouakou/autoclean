import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Center(
          child: Text('Stats Page',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold))),
    ));
  }
}
