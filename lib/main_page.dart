import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/pages/config_page.dart';
import 'package:autoclean/features/laveurs/pages/list_laveurs.dart';
import 'package:autoclean/features/prestations/pages/caisse_page.dart';
import 'package:autoclean/features/prestations/pages/dashboard.dart';
import 'package:autoclean/features/prestations/pages/list_mvt_caisse.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';

import 'package:autoclean/features/prestations/services/caisse_notifier.dart';
import 'package:autoclean/features/tarification/pages/tarifs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isOwner = ref.watch(isOwnerProvider);

    final employeeModedestinations = [
      const NavigationDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home, color: Colors.white),
          label: 'Accueil'),
      const NavigationDestination(
        icon: Icon(Icons.payments),
        selectedIcon: Icon(Icons.payments, color: Colors.white),
        label: 'Mvt caisse',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        selectedIcon: Icon(Icons.person, color: Colors.white),
        label: 'Laveurs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.attach_money),
        selectedIcon: Icon(Icons.attach_money, color: Colors.white),
        label: 'Tarifs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        selectedIcon: Icon(Icons.person, color: Colors.white),
        label: 'Profil',
      ),
    ];

    final ownerModedestinations = [
      const NavigationDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home, color: Colors.white),
          label: 'Accueil'),
      const NavigationDestination(
        icon: Icon(Icons.history),
        selectedIcon: Icon(Icons.history, color: Colors.white),
        label: 'Historique',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        selectedIcon: Icon(Icons.person, color: Colors.white),
        label: 'Laveurs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.attach_money),
        selectedIcon: Icon(Icons.attach_money, color: Colors.white),
        label: 'Tarifs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        selectedIcon: Icon(Icons.person, color: Colors.white),
        label: 'Profil',
      ),
    ];
    caisse.when(
      data: (value) => print(
          'CaisseNotifierProvider: Caisse chargée avec succès UID: ${value.accountId}, date ouverture: ${Utils.dateFull.format(value.dateOuverture!)}'),
      error: (error, stackTrace) =>
          print('Erreur lors du chgt: ${error.toString()}'),
      loading: () => print('Chargement des données de la caisse'),
    );
    Color selectedColor =
        isOwner ? const Color(0xFFF3774D) : Colors.teal.shade300;

    List<Widget> body = isOwner
        ? [
            const Dashboard(),
            const CaissePage(),
            const ListLaveurs(),
            const TarifsPage(),
            const ConfigPage()
          ]
        : [
            const PrestationsPage(),
            const ListMvtsCaisse(),
            const ListLaveurs(),
            const TarifsPage(),
            const ConfigPage()
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
          destinations:
              isOwner ? ownerModedestinations : employeeModedestinations,
        ));
  }
}
