import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/prestations/models/caisse.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final caisseProvider = Provider.autoDispose<CaisseService>((ref) {
  final auth = ref.watch(authProvider);
  return CaisseService(authService: auth);
});

final userProvider = Provider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.currentUser;
});

final caisseFutureProvider = FutureProvider.autoDispose<String?>((ref) async {
  final auth = ref.watch(authProvider);
  final caisseApi = ref.watch(caisseProvider);
  final userUID = auth.currentUser?.uid ?? '';
  final idCaisseOuverte =
      await caisseApi.getIdCaisseOuverte(userAccountId: userUID);
  return idCaisseOuverte;
});

class CaisseService {
  final AuthService authService;
  Caisse? _caisseOuverte;

  CaisseService({required this.authService});

  final CollectionReference caisses =
      FirebaseFirestore.instance.collection("caisses");

  Caisse? get caisseOuverte => _caisseOuverte;

  Future<String> createNew(String userId) async {
    var maintenant = DateTime.now();
    final idCaisse = await caisses.add({
      'id': '',
      'libelle': 'Journee du ${Utils.dateShort.format(maintenant)}',
      'caissier': authService.currentUser!.email!,
      'dateOuverture': Timestamp.now(),
      'dateFermeture': null,
      'soldeInitial': 0.0,
      'recette': 0.0,
      'accountId': userId
    });

    // Creer la caisse
    print('Caisse service: Nouvelle caisse créée ${idCaisse.id}');
    return idCaisse.id;
  }

  Future get(String userId) async {
    print('Caisse service:  -> get method');
    QuerySnapshot result = await caisses
        .where('accountId', isEqualTo: userId)
        .where('dateFermeture', isNull: true)
        .orderBy('dateOuverture', descending: true)
        .get();
    final nb = result.docs.length;
    if (result.docs.isEmpty) {
      print('Caisse service: Aucune correspondance!');
      //   final caisseId = await createNew(userId);

      //   return caisses.doc(caisseId).get();
    } else {
      print('Caisse service: $nb caisse(s) touvée(s)!');
      return result.docs.first;
    }
  }

  Future<String> add(Caisse caisse) async {
    final documentRef = await caisses.add(caisse.toJson());
    Utils.showSuccessMessage(message: "Caisse enregistrée!");
    return documentRef.id;
  }

  Future<String> update(Caisse caisse, String id) async {
    caisses.doc(id).update(caisse.toJson());
    Utils.showSuccessMessage(message: "Caisse $id enregistrée!");
    return id;
  }

  Future<void> delete(String docId) async {
    caisses.doc(docId).delete();
  }

  Future<Caisse?> getCaisseOuverte({required String userAccountId}) async {
    DocumentSnapshot<Map<String, dynamic>> result = await get(userAccountId);
    print('Caisse ouverte: ${result.id}  userAccountId: $userAccountId');
    _caisseOuverte = Caisse.fromJson(result.data()!);
    return _caisseOuverte;
  }

  Future<String?> getIdCaisseOuverte({required String userAccountId}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result = await get(userAccountId);
      print('Caisse ouverte: ${result.id}  userAccountId: $userAccountId');
      return result.id;
    } catch (error) {
      error.toString();
    }
    return null;
  }

  Stream<QuerySnapshot> getCaisses(String userUID) {
    return caisses
        .orderBy('dateOuverture', descending: true)
        .where('accountId', isEqualTo: userUID)
        .snapshots();
  }

  Future<Caisse> getById(String id) async {
    DocumentSnapshot caisse = await caisses.doc(id).get();
    return Caisse.fromFirestore(map: caisse);
  }
}

/*       //garder pour reference
      _caisseOuverte = Caisse.fromJson({
        'id': idCaisse.id,
        'libelle': 'Journee du ${Utils.dateShort.format(maintenant)}',
        'caissier': authService.currentUser!.email!,
        'dateOuverture': Timestamp.now(),
        'dateFermeture': null,
        'soldeInitial': 0.0,
        'recette': 0.0,
        'accountId': userId
      });
      
       */