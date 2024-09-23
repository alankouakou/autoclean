import 'package:autoclean/features/authentification/models/account.dart';
import 'package:autoclean/features/authentification/models/statut_compte.dart';

import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/features/authentification/services/account_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../main_page.dart';

final _formKey = GlobalKey<FormState>();

class StepperSignup extends StatefulWidget {
  const StepperSignup({super.key});

  @override
  State<StepperSignup> createState() => _StepperSignupState();
}

class _StepperSignupState extends State<StepperSignup> {
  final AuthService auth = AuthService();

  final AccountService entrepriseService = AccountService();

  int _currentIndex = 0;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cnfrmPasswordController = TextEditingController();

  final nomCommController = TextEditingController();
  final telephoneController = TextEditingController();
  final villeController = TextEditingController();
  final quartierController = TextEditingController();
  final pinController = TextEditingController();

  Future<String?> createUser(String email, String password) async {
    try {
      final user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        //TODO Enregistrer le compte

        // Navigator.pushReplacement(
        //   context, MaterialPageRoute(builder: (context) => const MainPage()));
        return user.uid;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }

    return null;
  }

  void createAccount() async {
    // créer users
    // ensuite
    //creer entreprise
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey.shade100,
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF3774D))),
        child: Stepper(
            type: StepperType.horizontal,
            controlsBuilder: (context, details) =>
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (_currentIndex != 0)
                    OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF3774D)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: const Text('Retour')),
                  const SizedBox(
                    width: 5,
                  ),
                  if (_currentIndex < 2)
                    ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white),
                        child: const Text('Suivant')),
                  if (_currentIndex == 2)
                    ElevatedButton(
                        onPressed: () async {
                          //On crée tous les comptes ici et on appelle l'ecran de confirmation
                          print('Signup - Création des comptes');
                          final userId = await createUser(
                              emailController.text, passwordController.text);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white),
                        child: const Text('Terminer')),
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
                  title: const Text(''),
                  content: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informations Connexion',
                                style: TextStyle(
                                    color: Color(0xFFF3774D),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                validator: (value) =>
                                    value != null ? null : 'Champ obligatoire',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: emailController,
                                decoration: InputDecoration(
                                    hintText: 'E-mail',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.white,
                                    filled: true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) =>
                                    value == null ? 'Champ obligatoire' : null,
                                autovalidateMode: AutovalidateMode.always,
                                decoration: InputDecoration(
                                    //label: Text('Prenom'),
                                    hintText: 'Mot de passe...',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.white,
                                    filled: true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                obscureText: true,
                                controller: cnfrmPasswordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Renseignez le mot de passe';
                                  } else if ((value.length ==
                                          passwordController.text.length) &&
                                      (value
                                          .contains(passwordController.text))) {
                                    return null;
                                  } else {
                                    return 'Verifiez le mot de passe';
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: 'Confirmez le password...',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.white,
                                    filled: true),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ]),
                    ),
                  )),
              Step(
                isActive: _currentIndex >= 1,
                title: const Text(''),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations générales',
                        style: TextStyle(
                            color: Color(0xFFF3774D),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    const Text(
                        'Renseignez les informations relatives au lavage, adresse géographique, contact, etc...'),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: nomCommController,
                        decoration: InputDecoration(
                            hintText: 'Nom de l\'entreprise',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                            fillColor: Colors.white,
                            filled: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: telephoneController,
                        validator: (value) =>
                            value != null ? null : 'Champ obligatoire',
                        decoration: InputDecoration(
                            hintText: 'Contact téléphonique',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                            fillColor: Colors.white,
                            filled: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: villeController,
                        decoration: InputDecoration(
                            hintText: 'Ville',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                            fillColor: Colors.white,
                            filled: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: quartierController,
                        decoration: InputDecoration(
                            hintText: 'Quartier',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none),
                            fillColor: Colors.white,
                            filled: true),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
              Step(
                  isActive: _currentIndex >= 2,
                  title: const Text(''),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Code PIN',
                          style: TextStyle(
                              color: Color(0xFFF3774D),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20.0),
                      const Text(
                          'Votre code PIN vous permet de passer en mode propriétaire. En mode propriétaire, vous avez accès à tous les menus de l\'application : Tableau de bord, Historique, Tarifs, Rapports ...'),
                      const SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: PinCodeTextField(
                          autoFocus: true,
                          appContext: context,
                          controller: pinController,
                          keyboardType: TextInputType.phone,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.circle,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Colors.white,
                          ),
                          validator: (value) =>
                              value!.length == 5 ? null : 'Champ obligatoire',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          length: 5,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      /*
                      const Text(
                          'Cliquez sur Terminer pour finaliser la création de votre compte'),
                      const Text(
                          'Vous pouvez contacter le service client pour vous aider à configurer vos tarifs'),
                      const SizedBox(height: 20.0),
                      */
                    ],
                  )),
            ]),
      ),
    );
  }
}
