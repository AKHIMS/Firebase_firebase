// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/text_filde.dart';
import 'package:flutter_application_1/model/button.dart';
import 'package:flutter_application_1/view/colour.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTab;
  const RegisterPage({
    super.key,
    required this.onTab,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final conformpasswordcontroller = TextEditingController();

  void siginUP() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordTextController.text != conformpasswordcontroller.text) {
      Navigator.pop(context);
      displayMessage("Password don't match!");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexstringTocolor("CB2B93"),
                hexstringTocolor("9546c4"),
                hexstringTocolor("5e61f4"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add your image here
                    Image.asset(
                      'images/logo2.png', // Replace with your image path
                      height: 200, // Adjust height as needed
                      width: 200, // Adjust width as needed
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Let\'s create an account',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 25),
                    MyTextFieeld(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextFieeld(
                      controller: passwordTextController,
                      hintText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextFieeld(
                      controller: conformpasswordcontroller,
                      hintText: 'Confirm Password',
                      obscureText: true,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyButton(onTab: siginUP, text: 'Sign Up',),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTab,
                          child: const Text(
                            'Login now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
