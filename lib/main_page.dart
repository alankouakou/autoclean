import 'package:autoclean/features/prestations/pages/caisse_page.dart';
import 'package:autoclean/features/authentification/pages/login.dart';
import 'package:autoclean/features/prestations/pages/prestations_page.dart';
import 'package:autoclean/features/prestations/pages/stats/stats_page.dart';
import 'package:autoclean/features/tarification/pages/tarifs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final indexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, required this.firebaseAuthId});
  final String firebaseAuthId;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  signOut() {
    AuthService().signOut();
    /*   Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
 */
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(indexProvider);
    Color selectedColor = Colors.teal.shade300;

    List<Widget> body = [
      PrestationsPage(accountId: widget.firebaseAuthId),
      const CaissePage(),
      const StatsPage(),
      const TarifsPage(),
    ];
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(Icons.power_settings_new), onPressed: signOut),
          ],
          backgroundColor: const Color(0xFFEEEEEE),
          title: const Text('',
              style: TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.bold)),
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
              icon: Icon(Icons.attach_money_outlined),
              selectedIcon:
                  Icon(Icons.attach_money_outlined, color: Colors.white),
              label: 'Recettes',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              selectedIcon: Icon(Icons.bar_chart, color: Colors.white),
              label: 'Stats',
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
