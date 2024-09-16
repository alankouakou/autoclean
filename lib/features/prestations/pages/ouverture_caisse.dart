import 'package:flutter/material.dart';

class OuvertureCaisse extends StatelessWidget {
  const OuvertureCaisse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text('Journée du 18/08/2024',
                        style: TextStyle(
                            color: Color(0xFFF3774D),
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        height: 65,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('08:00',
                            style: TextStyle(fontSize: 16))),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0)),
                        label: const Text('Solde initial'),
                        suffixText: 'FCFA',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                        height: 90,
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                              width: 1.0, color: Colors.teal)),
                                      elevation: 0,
                                      backgroundColor: Colors.teal),
                                  child: const Text('Ouvrir',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)))
                            ]),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
