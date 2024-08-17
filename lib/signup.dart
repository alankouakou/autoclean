import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool isVisible = true;
  List loginCrees = ['admin', 'superadmin', 'user', 'alan', 'naomie', 'cesar'];

  void toggleVisibility() {
    setState(
      () {
        isVisible = !isVisible;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text('Signup Page',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _loginController,
                    validator: (value) => value!.isEmpty
                        ? null
                        : loginCrees.contains(value)
                            ? 'Login existe déjà'
                            : null, // Le login doit être unique
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        hintText: 'Login',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none),
                        fillColor: Colors.black12,
                        filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (value) => passwordValidator(value),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: isVisible,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none),
                      fillColor: Colors.black12,
                      filled: true,
                      suffixIcon: IconButton(
                        onPressed: toggleVisibility,
                        icon: isVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _repeatPasswordController,
                    validator: (value) => value!.isEmpty
                        ? null
                        : (value == _passwordController.text)
                            ? null
                            : 'Verifiez le mot de passe',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: isVisible,
                    decoration: InputDecoration(
                      hintText: 'Entrez à nouveau le mot de passe',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none),
                      fillColor: Colors.black12,
                      filled: true,
                      suffixIcon: IconButton(
                        onPressed: toggleVisibility,
                        icon: isVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                ),
                // FilledButton(onPressed: () {},style: ButtonStyle(shape: RoundedRectangleBorder()), child: const Text('Valider')),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.validate();
                    loginCrees.add(_loginController.text);
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Text(
                                  'Compte ${_loginController.text} ajouté!'),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(double.infinity, 50),
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                child: const Text('OK'))
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.infinity, 50),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0))),
                  child: const Text('Créer le compte',
                      style: TextStyle(fontSize: 16)),
                )
              ]),
            ),
          ),
        ));
  }

  passwordValidator(String? value) {
    var resultCheck = value!.isEmpty
        ? null
        : value.length < 4
            ? 'Le mot de passe doit comporter au minimum 4 caractères'
            : null;

    return resultCheck;
  }
}


/*
value.length < 8
            ? 'Le mot de passe doit comporter au minimum 8 caractères'
            : !value.contains(RegExp(r'[0-9]{1,}'))
                ? 'Le mot de passe doit comporter un chiffre'
                : !value.contains(
                        RegExp(r'[$€¨¿@&§°\’\"\!\^\*\-\_\+\/\(\)]{1,}'))
                    ? 'Le mot de passe doit comporter un caractère spécial'
                    : null;
*/