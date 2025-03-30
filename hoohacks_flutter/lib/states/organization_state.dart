import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/organization_model.dart';

class OrganizationState extends ChangeNotifier {
  List<OrganizationModel> organizations = [];

  StreamSubscription<QuerySnapshot>? organizationSubscription;

  OrganizationState() {
    organizationSubscription?.cancel();
    loadOrganizations();
    listenToOrganizations();
  }

  Future<void> loadOrganizations() async {
    organizations = await getOrganizations();
    notifyListeners();
  }

  void listenToOrganizations() {
    organizationSubscription = FirebaseFirestore.instance
        .collection('organizations')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
          organizations =
              snapshot.docs.map((DocumentSnapshot doc) {
                return OrganizationModel.fromMap(
                  doc.data()! as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();
          notifyListeners();
        });
  }

  @override
  void dispose() {
    organizationSubscription?.cancel();
    super.dispose();
  }
}
