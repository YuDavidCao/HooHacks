import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_auth.dart';
import 'package:hoohacks/home_page.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSignUp = true;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (_isSignUp) ? "Sign Up" : "Sign In",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (_isSignUp)
            Padding(
              padding: middleWidgetPadding,
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Padding(
            padding: middleWidgetPadding,
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    (_isPasswordVisible)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText: _isPasswordVisible,
            ),
          ),
          if (_isSignUp)
            Padding(
              padding: middleWidgetPadding,
              child: TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      (_isConfirmPasswordVisible)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _isConfirmPasswordVisible,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (_isSignUp)
                    ? "Already have an account?"
                    : "Don't have an account?",
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text((_isSignUp) ? "Sign In" : "Sign Up"),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              UserCredential? userCredential;
              if (!emailRegex.hasMatch(_emailController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please use a valid UVA email')),
                );
                return;
              }
              if (_isSignUp) {
                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }
                userCredential = await signUpWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                  context,
                );
                if (userCredential != null) {
                  await userCredential.user!.updateDisplayName(
                    _usernameController.text,
                  );
                }
              } else {
                userCredential = await logInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                  context,
                );
              }
              if (userCredential != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            },
            child: Text((_isSignUp) ? "Sign Up" : "Sign In"),
          ),
        ],
      ),
    );
  }
}
