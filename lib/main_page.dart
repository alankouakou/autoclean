import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/pages/caisse_page.dart';
import 'package:autoclean/features/prestations/pages/list_mvt_caisse.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';
import 'package:autoclean/features/prestations/pages/saisie_mvt_caisse.dart';
import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/tarification/pages/tarifs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/printing/services/printing_service.dart';

import 'package:autoclean/features/authentification/services/auth_service.dart';

final indexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  signOut() async {
    AuthService().signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(indexProvider);
    final auth = ref.watch(authProvider);
    final caisse = ref.watch(caisseNotifierProvider);
    caisse.when(
      data: (value) => print(
          'CaisseNotifierProvider: Caisse chargée avec succès UID: ${value.accountId}, date ouverture: ${Utils.dateFull.format(value.dateOuverture!)}'),
      error: (error, stackTrace) =>
          print('Erreur lors du chgt: ${error.toString()}'),
      loading: () => print('Chargement des données de la caisse'),
    );
    Color selectedColor = Colors.teal.shade300;

    List<Widget> body = [
      const PrestationsPage(),
      const CaissePage(),
      const ListMvtsCaisse(),
      const TarifsPage(),
    ];
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(Icons.power_settings_new),
                onPressed: () {
                  signOut();
                }),
          ],
          backgroundColor: const Color(0xFFEEEEEE),
          title: GestureDetector(
            onTap: () {},
            child: Text(auth.currentUser?.email ?? 'Anonyme',
                style: const TextStyle(color: Colors.black54)),
          ),
        ),
        body: Center(
          child: body[selectedIndex],
        ),
        bottomNavigationBar: NavigationBar(
          indicatorColor: selectedColor,
          backgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            ref.read(indexProvider.notifier).state = index;
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home, color: Colors.white),
                label: 'Accueil'),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history, color: Colors.white),
              label: 'Historique',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments),
              selectedIcon: Icon(Icons.payments, color: Colors.white),
              label: 'Mvt caisse',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_outlined, color: Colors.white),
              label: 'Tarifs',
            ),
          ],
        ));
  }
}
