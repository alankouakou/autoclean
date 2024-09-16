import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/tarification/services/tarifs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const couleurs = [
  Colors.grey,
  Colors.blue,
  Color(0xFFFB8C00),
  Colors.teal,
  Colors.purple,
  Color(0xFFEC407A),
  Colors.lightBlue,
  Color(0xFFF3774D)
];

class TarifListWidget extends ConsumerWidget {
  const TarifListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarifs = ref.watch(tarifsFutureProvider);
    final nbCouleurs = couleurs.length;
    int indexCouleur = 0;

    return Container(
      // I've replaced the SizedBox for Container
      //height: 10,
      child: tarifs.when(
        data: (tarifs) {
          return ListView.builder(
            itemCount: tarifs.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Card(
                    color: Colors.grey.shade100,
                    child: ListTile(
                      title: Text(tarifs[index].libelle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ...tarifs[index].options.map(
                        (option) {
                          indexCouleur++;
                          return Chip(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            side: BorderSide.none,
                            backgroundColor: couleurs[indexCouleur % nbCouleurs]
                                .withOpacity(0.9),
                            label: Text(
                                '${option.libelle} ${Utils.formatCFA(option.prix)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            avatar: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black.withOpacity(0.3),
                                child: Text(option.libelle[0],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12))),
                          );
                        },
                      )
                    ],
                  )
                ],
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
            child: Text('${error.toString()} \n\n ${stackTrace.toString()}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red))),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
