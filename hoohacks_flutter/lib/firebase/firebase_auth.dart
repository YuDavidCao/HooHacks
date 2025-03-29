import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<UserCredential?> signUpWithEmailAndPassword(
  String emailAddress,
  String password,
  BuildContext context,
) async {
  try {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (context.mounted) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The password provided is too weak.')),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.code)));
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error signing up')));
    }
  }
  return null;
}

Future<UserCredential?> logInWithEmailAndPassword(
  String emailAddress,
  String password,
  BuildContext context,
) async {
  try {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (context.mounted) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided for that user.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.code)));
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error logging in')));
    }
  }
  return null;
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<void> deleteAccount() async {
  await FirebaseAuth.instance.currentUser!.delete();
}
