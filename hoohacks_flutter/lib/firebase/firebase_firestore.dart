import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoohacks/models/activity_model.dart';

Future<bool> addActivity(
  String activityName,
  String description,
  String category,
  double latitude,
  double longitude,
  DateTime startDate,
  DateTime endDate,
  List<String> categories,
  String contactEmail,
) async {
  try {
    // Get a reference to the Firestore instance
    final firestore = FirebaseFirestore.instance;

    ActivityModel activityModel = ActivityModel(
      publisher: FirebaseAuth.instance.currentUser?.uid ?? '',
      title: activityName,
      description: description,
      createdDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      latitude: latitude,
      longitude: longitude,
      categories: categories,
      participants: [],
      contactEmail: contactEmail,
      upvotes: 0,
      downvotes: 0,
      organizationOnly: false, // hard coded
      // years: years,
    );

    // Create a new document in the "activities" collection
    await firestore.collection('activities').add(activityModel.toMap());
    return true;
  } catch (e) {
    print("Error adding activity: $e");
  }
  return false;
}
