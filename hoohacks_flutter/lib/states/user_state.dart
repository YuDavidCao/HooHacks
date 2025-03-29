import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/models/user_model.dart';

class UserState extends ChangeNotifier {
  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  void setUserModel(UserModel userModel) {
    _userModel = userModel;
  }

  void clearUserModel() {
    _userModel = null;
  }

  void getUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              setUserModel(
                UserModel.fromMap(
                  documentSnapshot.data() as Map<String, dynamic>,
                  documentSnapshot.id,
                ),
              );
            }
          });
    }
  }

  UserState() {
    subscription?.cancel();
    getUser();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        clearUserModel();
      } else {
        subscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
              if (documentSnapshot.exists) {
                setUserModel(
                  UserModel.fromMap(
                    documentSnapshot.data() as Map<String, dynamic>,
                    documentSnapshot.id,
                  ),
                );
              }
            });
      }
    });
  }

  StreamSubscription<DocumentSnapshot>? subscription;

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}
