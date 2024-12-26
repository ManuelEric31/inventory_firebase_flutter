import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_firebase/screens/auth/login_screen.dart';
import 'package:inventory_firebase/widgets/textfields/login/password_login_textfield.dart';
import 'package:inventory_firebase/widgets/textfields/register/re_password_login_textfield.dart';
import 'package:inventory_firebase/widgets/textfields/login/username_login_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController controllerTypedUsername = TextEditingController();
  final TextEditingController controllerTypedPassword = TextEditingController();
  final TextEditingController controllerReTypedPassword =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    controllerTypedUsername.dispose();
    controllerTypedPassword.dispose();
    controllerReTypedPassword.dispose();
    super.dispose();
  }

  void _registerWithFirebase() async {
    final username = controllerTypedUsername.text;
    final password = controllerTypedPassword.text;
    final rePassword = controllerReTypedPassword.text;

    if (username.isEmpty || password.isEmpty || rePassword.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password must be filled!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != rePassword) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and Re-entered password must be the same!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );

      controllerTypedUsername.clear();
      controllerTypedPassword.clear();
      controllerReTypedPassword.clear();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'The email is already in use by another account.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else {
        message = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create an Account!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const Text('Sign up to get started'),
                const SizedBox(height: 40),
                UsernameLoginTextField(
                    controllerTyped: controllerTypedUsername),
                PasswordLoginTextfield(
                    controllerTyped: controllerTypedPassword),
                RePasswordLoginTextfield(
                    controllerTyped: controllerReTypedPassword),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: MaterialButton(
                      height: 48,
                      onPressed: _registerWithFirebase,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: const Color.fromARGB(255, 0, 28, 53),
                      child: const Text(
                        'Register!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Login Here!'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
