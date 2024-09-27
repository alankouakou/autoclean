import 'package:autoclean/features/laveurs/pages/ajout_laveur.dart';
import 'package:autoclean/features/laveurs/pages/edit_laveur.dart';
import 'package:autoclean/features/laveurs/services/laveur_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListLaveurs extends ConsumerStatefulWidget {
  const ListLaveurs({super.key});

  @override
  ConsumerState<ListLaveurs> createState() => _ListLaveursState();
}

class _ListLaveursState extends ConsumerState<ListLaveurs> {
  //final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nomController.dispose();
    contactController.dispose();
    super.dispose();
  }

  String? notEmpty(String? val) {
    return val == null || val.isEmpty ? 'Champ obligatoire' : null;
  }

  Widget customTextField(
      {required String hintText,
      required TextEditingController textController,
      required String? Function(String? val) validator}) {
    return TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.number,
        validator: validator,
        controller: textController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            hintText: hintText,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            fillColor: Colors.grey.shade300));
  }

  @override
  Widget build(BuildContext context) {
    final laveursRepo = ref.watch(laveurProvider);

    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(children: [
              Container(
                  color: Colors.white,
                  child: const Text('Laveurs',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.teal))),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AjoutLaveur()));
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50.0),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  child: const Icon(Icons.person_add,
                      size: 30.0, color: Colors.white),
                ),
              ),
              Expanded(
                child: laveursRepo.when(
                  data: (data) {
                    return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final laveur = data[index];
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: ListTile(
                                  leading: laveur.actif == true
                                      ? const Checkbox(
                                          value: true, onChanged: null)
                                      : const Checkbox(
                                          value: false, onChanged: null),
                                  title: Text(
                                      '${laveur.nom} - ${laveur.contact}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => EditLaveur(
                                                  laveurId: laveur.id,
                                                  nom: laveur.nom,
                                                  contact: laveur.contact)));
                                    },
                                  ),
                                ),
                              ));
                        });
                  },
                  error: (e, s) {
                    print(s.toString());
                    return Center(child: Text(e.toString()));
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              )
            ])));
  }
}
