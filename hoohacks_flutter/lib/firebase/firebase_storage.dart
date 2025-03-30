import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
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
        .child("activities/$docId.png")
        .putFile(file);
    String downloadUrl = await activitySnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to upload activity picture")),
    );
    return null;
  }
}

Future<void> deleteActivityImage(String docId) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    await storageRef.child("activities/$docId.png").delete();
  } catch (e) {
    print(e);
  }
}

Future<String?> uploadProfilePicture(File file, BuildContext context) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final taskSnapshot = await storageRef
        .child(
          "avatar/${FirebaseAuth.instance.currentUser!.uid}/profile_picture.png",
        )
        .putFile(file);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to upload profile picture")),
    );
    return null;
  }
}

Future<String?> addOrganizationPicture(String id, File file) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final taskSnapshot = await storageRef
        .child("organizations/$id/profile_picture.png")
        .putFile(file);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<void> deleteOrganizationPicture(String id) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    await storageRef.child("organizations/$id/profile_picture.png").delete();
  } catch (e) {
    print(e);
  }
}
