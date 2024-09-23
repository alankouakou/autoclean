import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  final CollectionReference entreprisesCollection =
      FirebaseFirestore.instance.collection('entreprises');
  Future<String> add(Map<String, dynamic> entreprise) async {
    final docId = await entreprisesCollection.add(entreprise);

    return docId.id;
  }
}
