import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class StepperSignup extends StatefulWidget {
  const StepperSignup({super.key});

  @override
  State<StepperSignup> createState() => _StepperSignupState();
}

class _StepperSignupState extends State<StepperSignup> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal)),
        child: Stepper(
            type: StepperType.horizontal,
            controlsBuilder: (context, details) => Row(children: [
                  OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                      child: const Text('Retour')),
                  const SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white),
                      child: const Text('Suivant')),
                ]),
            onStepContinue: () {
              setState(
                () {
                  if (_currentIndex <= 1) {
                    _currentIndex += 1;
                  }
                },
              );
            },
            onStepCancel: () {
              setState(
                () {
                  if (_currentIndex > 0) {
                    _currentIndex -= 1;
                  }
                },
              );
            },
            onStepTapped: (value) {
              setState(
                () {
                  _currentIndex = value;
                },
              );
            },
            currentStep: _currentIndex,
            steps: [
              Step(
                  isActive: _currentIndex >= 0,
                  title: const Text('Etape 1',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Infos Générales',
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                validator: (value) => value!.contains('e')
                                    ? 'Données invalides'
                                    : null,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                    hintText: 'Login',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.black12,
                                    filled: true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    //label: Text('Prenom'),
                                    hintText: 'Mot de passe...',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.black12,
                                    filled: true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Contact téléphonique',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.black12,
                                    filled: true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Nom complet',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.black12,
                                    filled: true),
                              ),
                            ),
                          ]),
                    ),
                  )),
              Step(
                isActive: _currentIndex >= 1,
                title: const Text('Etape 2'),
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accès administrateur & standard',
                        style: TextStyle(
                            color: Colors.teal,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'Vous aurez besoin du compte administrateur pour accéder aux fonctionnalité complètes'),
                    Text(
                        "L'accès standadrd vous permet néanmoins d'effectuer les tâches de base: Enregistrer les prestations"),
                  ],
                ),
              ),
              Step(
                  isActive: _currentIndex >= 2,
                  title: const Text('Fin'),
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Configuration tarif',
                          style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Veuillez contacter le 778 pour la configuration de vos tarifs.')
                    ],
                  )),
            ]),
      ),
    );
  }
}
