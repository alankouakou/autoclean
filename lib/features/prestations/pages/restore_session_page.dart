import 'package:autoclean/main_page.dart';
import 'package:autoclean/providers/prestation_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestoreSessionPage extends ConsumerWidget {
  const RestoreSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Restore Data'),
        ),
        body: Column(
          children: [
            const Text(
                'Voulez-vous restaurer les donnée de la précédente session?'),
            Row(children: [
              ElevatedButton(
                  onPressed: () {
                    //ref.read(prestationsProvider.notifier).clear();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainPage()));
                  },
                  child: const Text('Non')),
              ElevatedButton(
                  onPressed: () {
                    ref.read(restoreData.notifier).state = true;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainPage()));
                  },
                  child: const Text('Oui')),
            ])
          ],
        ));
  }
}
