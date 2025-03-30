import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:http/http.dart' as http;

Future<List<ActivityModel>> getFilteredActivities(
  double longitude,
  double latitude,
  List<String> categories,
  String distance,
  String searchString,
) async {
  print(longitude);
  print(latitude);
  print(categories);
  print(distance);
  print(searchString);
  print(disToMiles(distance));
  final response = await http.post(
    Uri.parse("$baseUrl/get-activity"),
    body: jsonEncode({
      "Uid": FirebaseAuth.instance.currentUser!.uid,
      "Longitude": longitude,
      "Latitude": latitude,
      "Categories": categories,
      "Distances": disToMiles(distance),
      "SearchString": searchString,
    }),
    headers: {"Content-Type": "application/json"},
  );
  return (jsonDecode(response.body)["activities"] as List)
      .map((e) => ActivityModel.fromFlask(e as Map<String, dynamic>, e['Id']))
      .toList();
}

double disToMiles(String distance) {
  switch (distance) {
    case "0.5 miles":
      return 0.5;
    case "1 mile":
      return 1;
    case "2 miles":
      return 2;
    case "5 miles":
      return 5;
    case "10 miles":
      return 10;
    default:
      return 10000;
  }
}

Future<void> storeDocumentInChroma(
  String title,
  String description,
  String docId,
  DateTime endDate,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/store-activity"),
    body: jsonEncode({
      "Id": docId,
      "Title": title,
      "Description": description,
      "EndDate": endDate.microsecondsSinceEpoch,
    }),
    headers: {"Content-Type": "application/json"},
  );
}
