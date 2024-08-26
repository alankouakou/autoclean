import 'package:autoclean/features/authentification/services/auth_service.dart';
import 'package:autoclean/main_page.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool isVisible = true;

  Future<void> signUp(String email, String password) async {
    final user = await AuthService().createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    if (user != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(firebaseAuthId: user.uid)));
    }
  }

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
                  child: Text('Nouveau compte',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) => value!.isEmpty
                        ? 'Rensaignez le champ e-mail'
                        : null, // Le login doit être unique
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        hintText: 'E-mail',
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
                ElevatedButton(
                  onPressed: () {
                    // _formKey.currentState!.validate();
                    signUp(_emailController.text, _passwordController.text);
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
