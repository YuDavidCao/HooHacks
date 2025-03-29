import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Future<String?> uploadActivityImage(
  File file,
  String docId,
  BuildContext context,
) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final activitySnapshot = await storageRef
        .child("activities/$docId")
        .putFile(file);
    String downloadUrl = await activitySnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to upload activity picture")),
    );
    return null;
  }
}
