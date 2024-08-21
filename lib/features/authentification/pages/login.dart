import 'package:autoclean/features/authentification/pages/reset_password.dart';
import 'package:autoclean/main_page.dart';

import 'signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String response = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkHisto() async {
    final sp = await SharedPreferences.getInstance();
    response = sp.getString('historique') ?? '{}';
  }

  Future<void> signinWithEmailAndPassword(String email, String password) async {
    final user = await AuthService().signinWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    checkHisto();
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Car Wash v1.0',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.teal)),
              Container(
                  height: 180.0,
                  width: 180.0,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/car.jpeg'),
                    radius: 70,
                  )),
              //Image.asset('assets/car.jpeg')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 30),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      hintText: 'E-mail',
                      suffixIcon: Icon(Icons.person)),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      hintText: 'Password',
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          //borderSide: BorderSide(color: Color(0xFFF33D06)),
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      suffixIcon: _obscureText == true
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: const Icon(Icons.visibility))
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: const Icon(Icons.visibility_off))),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResetPasswordPage())),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Mot de passe oublié?',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFFFF6F00))),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30.0),
                child: OutlinedButton(
                    onPressed: () {
                      signinWithEmailAndPassword(
                          _emailController.text, _passwordController.text);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous n\'avez pas de compte?',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp())),
                    child: const Text('Créez un compte',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6F00))),
                  )
                ],
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ));
  }
}


/*

*/