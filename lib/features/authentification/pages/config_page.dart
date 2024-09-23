import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerMode = ref.watch(isOwnerProvider);
    final String libelleProfilActif = ownerMode ? 'Proprietaire' : 'Caissier';

    return Scaffold(
        appBar: AppBar(
            title: const Text('Configuration',
                style: TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: Column(children: [
            Text('Profil actif: $libelleProfilActif',
                style: const TextStyle(color: Colors.teal, fontSize: 20)),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                ownerMode
                    ? ref.read(isOwnerProvider.notifier).state = false
                    : showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PinCodeTextField(
                                    keyboardType: TextInputType.number,
                                    autoFocus: true,
                                    appContext: context,
                                    length: 5,
                                    pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.circle),
                                    onCompleted: (value) {
                                      ref.read(isOwnerProvider.notifier).state =
                                          (value == '54321') ? true : false;
                                      Navigator.of(context).pop();
                                    }),
                              ],
                            ),
                          );
                        });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3774D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: ownerMode
                  ? const Text('Basculer en mode Caissier')
                  : const Text('Basculer en mode Propriétaire'),
            ),
          ]),
        ));
  }
}
