import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/activity_model.dart';

class ActivityState extends ChangeNotifier {
  List<ActivityModel> activities = [];

  StreamSubscription<QuerySnapshot>? activitySubscription;

  ActivityState() {
    activitySubscription?.cancel();
    loadActivities();
    listenToActivities();
  }

  Future<void> loadActivities() async {
    activities = await getActivities();
    notifyListeners();
  }

  void listenToActivities() {
    activitySubscription = FirebaseFirestore.instance
        .collection('activities')
        .orderBy('StartDate', descending: true)
        .where('EndDate', isNotEqualTo: DateTime.now())
        .snapshots()
        .listen((QuerySnapshot snapshot) {
          activities =
              snapshot.docs.map((DocumentSnapshot doc) {
                return ActivityModel.fromMap(
                  doc.data()! as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();
          notifyListeners();
          // bool hasChanges = false;
          // snapshot.docChanges.forEach((DocumentChange docChange) {
          //   if (docChange.type == DocumentChangeType.added) {
          //     hasChanges = true;
          //   }
          // });
          // if (hasChanges) {
          //   activities =
          //       snapshot.docs
          //           .map(
          //             (DocumentSnapshot doc) => ActivityModel.fromMap(
          //               doc.data()! as Map<String, dynamic>,
          //               doc.id,
          //             ),
          //           )
          //           .toList();
          //   notifyListeners();
          // }
        });
  }

  @override
  void dispose() {
    activitySubscription?.cancel();
    super.dispose();
  }
}
