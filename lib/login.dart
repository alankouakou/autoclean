import 'package:autoclean/main_page.dart';

import 'package:autoclean/signup.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Car Wash Manager v1.0',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.teal)),
              Container(
                  height: 200.0,
                  width: 200.0,
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
                  controller: _loginController,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 30),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      hintText: 'Username',
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
              const SizedBox(height: 10.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30.0),
                child: OutlinedButton(
                    onPressed: () {
                      if (_loginController.text == 'test' &&
                          _passwordController.text == 'test') {
                        _loginController.clear();
                        _passwordController.clear();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainPage()));
                      } else {
                        _loginController.clear();
                        _passwordController.clear();
                      }
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
              )
            ]),
          ),
        ));
  }
}
