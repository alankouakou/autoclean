import 'package:autoclean/core/utils.dart';
import 'package:autoclean/features/prestations/models/prestation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final CollectionReference prestations =
      FirebaseFirestore.instance.collection('prestations');

  final CollectionReference caisses =
      FirebaseFirestore.instance.collection('caisses');

  void addPrestation(Prestation prestation) async {
    await prestations.add(prestation.toJson());
    Utils.showSuccessMessage(message: "Prestation enregistrée!");
  }

  void deletePrestation(String docId) {
    prestations.doc(docId).delete();
  }

  void updatePrestation(String docId, Prestation newPrestation) {
    prestations.doc(docId).update(newPrestation.toJson());
  }

  Stream<QuerySnapshot> getPrestations() {
    return prestations.orderBy('datePrestation', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getCaisses() {
    return caisses
        .orderBy('dateOuverture', descending: true)
        // .where('dateFermeture', isNull: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPrestationsByUID(String prmAccountId) {
    return prestations
        .orderBy('datePrestation', descending: true)
        .where('accountId', isEqualTo: prmAccountId)
        .snapshots();
  }

  Future<QuerySnapshot> dataFromFirestore() async {
    QuerySnapshot results =
        await prestations.orderBy('datePrestation', descending: true).get();
    print('Inside firestore service: ${results.docs.length}');
    return results;
  }
}
