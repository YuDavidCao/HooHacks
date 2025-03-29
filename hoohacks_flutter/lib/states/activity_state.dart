import 'package:flutter/material.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/activity_model.dart';

class ActivityState extends ChangeNotifier {
  List<ActivityModel> activities = [];

  ActivityState() {
    loadActivities();
  }

  Future<void> loadActivities() async {
    activities = await getActivities();
    notifyListeners();
  }
}
