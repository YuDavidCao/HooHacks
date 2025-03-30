import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/firebase/firebase_storage.dart';
import 'package:hoohacks/firebase/flask_endpint.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/models/organization_model.dart';
import 'package:hoohacks/models/user_model.dart';

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
  String locationName,
  String? organizationId,
  File? image,
  BuildContext context,
) async {
  try {
    // Get a reference to the Firestore instance
    final firestore = FirebaseFirestore.instance;

    DocumentReference d = firestore.collection('activities').doc();

    storeDocumentInChroma(activityName, description, d.id, endDate);

    String? downloadUrl;
    if (image != null) {
      downloadUrl = await uploadActivityImage(image, d.id, context);
    }

    print("Download URL: $downloadUrl");

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
      organization: organizationId,
      locationName: locationName,
      organizationOnly: false, // hard coded
      imageUrl: downloadUrl,
    );
    d.set(activityModel.toMap());
    return true;
  } catch (e) {
    print("Error adding activity: $e");
  }
  return false;
}

Future<bool> updateActivityImageUrl(String activityId, String imageUrl) async {
  try {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('activities').doc(activityId).update({
      'imageUrl': imageUrl,
    });
    return true;
  } catch (e) {
    print("Error updating activity image URL: $e");
  }
  return false;
}

Future<List<ActivityModel>> getActivities() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot =
        await firestore
            .collection('activities')
            .orderBy('StartDate', descending: true)
            .where('EndDate', isGreaterThan: DateTime.now())
            .get();
    return snapshot.docs
        .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print("Error getting activities: $e");
  }
  return [];
}

Future<bool> joinActivity(String activityId, BuildContext context) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({
          'Participants': FieldValue.arrayUnion([
            FirebaseAuth.instance.currentUser?.uid,
          ]),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Joined activity!")));
    return true;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Error joining activity!")));
  }
  return false;
}

Future<bool> leaveActivity(String activityId, BuildContext context) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({
          'Participants': FieldValue.arrayRemove([
            FirebaseAuth.instance.currentUser?.uid,
          ]),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Left activity!")));
    return true;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Error leaving activity!")));
  }
  return false;
}

Future<bool> upvoteActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({'Upvotes': FieldValue.increment(1)});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'UpvotedActivities': FieldValue.arrayUnion([activityId]),
        });
    return true;
  } catch (e) {
    print("Error upvoting activity: $e");
  }
  return false;
}

Future<bool> cancelUpvoteActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({'Upvotes': FieldValue.increment(-1)});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'UpvotedActivities': FieldValue.arrayRemove([activityId]),
        });
    return true;
  } catch (e) {
    print("Error canceling upvote activity: $e");
  }
  return false;
}

Future<bool> downvoteActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({'Downvotes': FieldValue.increment(1)});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'DownvotedActivities': FieldValue.arrayUnion([activityId]),
        });
    return true;
  } catch (e) {
    print("Error downvoting activity: $e");
  }
  return false;
}

Future<bool> cancelDownvoteActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .update({'Downvotes': FieldValue.increment(-1)});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'DownvotedActivities': FieldValue.arrayRemove([activityId]),
        });
    return true;
  } catch (e) {
    print("Error canceling downvote activity: $e");
  }
  return false;
}

Future<bool> createUser(
  String username,
  String email,
  BuildContext context,
) async {
  try {
    final UserModel userModel = UserModel(
      name: username,
      email: email,
      username: username,
      bio: '',
      organization: [],
      participating: [],
      interest: [],
      upvotedActivities: [],
      downvotedActivities: [],
      savedActivities: [],
    );
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(userModel.toMap());
    return true;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Error creating user!")));
  }
  return false;
}

Future<UserModel> getUser(String userId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  } catch (e) {
    print("Error getting user: $e");
  }
  return UserModel(
    name: '',
    email: '',
    username: '',
    bio: '',
    organization: [],
    participating: [],
    interest: [],
    upvotedActivities: [],
    downvotedActivities: [],
    savedActivities: [],
  );
}

Future<bool> updateUser(
  String username,
  String email,
  String bio,
  BuildContext context,
) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'Username': username, 'Email': email, 'Bio': bio});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User updated!")));
    return true;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Error updating user!")));
  }
  return false;
}

void deleteActivity(String activityId, String? imageUrl) async {
  try {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await deleteActivityImage(activityId);
    }
    await FirebaseFirestore.instance
        .collection("activities")
        .doc(activityId)
        .delete();
  } catch (e) {
    print("Error deleting activity: $e");
  }
}

Future<ActivityModel?> getActivityById(String activityId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("activities")
            .doc(activityId)
            .get();
    return ActivityModel.fromMap(snapshot.data()!, snapshot.id);
  } catch (e) {
    print("Error getting activity by ID: $e");
  }
  return null;
}

Future<Map<String, dynamic>> getUserInfo(String userId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return snapshot.data()!;
  } catch (e) {
    print("Error getting user info: $e");
  }
  return {};
}

Future<void> saveActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'SavedActivities': FieldValue.arrayUnion([activityId]),
        });
  } catch (e) {
    print("Error saving activity: $e");
  }
}

Future<void> unsaveActivity(String activityId) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'SavedActivities': FieldValue.arrayRemove([activityId]),
        });
  } catch (e) {
    print("Error unsaving activity: $e");
  }
}

Future<void> createOrganization(
  String name,
  String description,
  String contactEmail,
  String location,
  File? image,
  BuildContext context,
) async {
  try {
    final firestore = FirebaseFirestore.instance;
    DocumentReference d = firestore.collection('organizations').doc();
    String? imageUrl;
    if (image != null) {
      imageUrl = await addOrganizationPicture(d.id, image);
    }
    OrganizationModel organizationModel = OrganizationModel(
      name: name,
      description: description,
      email: contactEmail,
      profilePicture: imageUrl,
      members: [],
      admins: [FirebaseAuth.instance.currentUser?.uid ?? ''],
      location: location,
      createdDate: DateTime.now(),
      activities: [],
    );
    d.set(organizationModel.toMap());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Organization created!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error creating organization!")),
    );
  }
}

Future<void> deleteOrganization(
  OrganizationModel organization,
  BuildContext context,
) async {
  try {
    if (organization.profilePicture != null) {
      await deleteOrganizationPicture(organization.id!);
    }
    await FirebaseFirestore.instance
        .collection("organizations")
        .doc(organization.id!)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Organization deleted!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error deleting organization!")),
    );
  }
}

Future<List<OrganizationModel>> getOrganizations() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('organizations').get();
    return snapshot.docs
        .map((doc) => OrganizationModel.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print("Error getting organizations: $e");
  }
  return [];
}

Future<void> joinOrganization(
  String organizationId,
  BuildContext context,
) async {
  try {
    await FirebaseFirestore.instance
        .collection("organizations")
        .doc(organizationId)
        .update({
          'Members': FieldValue.arrayUnion([
            FirebaseAuth.instance.currentUser?.uid,
          ]),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Joined organization!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error joining organization!")),
    );
  }
}

Future<void> leaveOrganization(
  String organizationId,
  BuildContext context,
) async {
  try {
    await FirebaseFirestore.instance
        .collection("organizations")
        .doc(organizationId)
        .update({
          'Members': FieldValue.arrayRemove([
            FirebaseAuth.instance.currentUser?.uid,
          ]),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Left organization!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error leaving organization!")),
    );
  }
}

Future<List<ActivityModel>> getActivitiesByOrganization(
  String organizationId,
) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot =
        await firestore
            .collection('activities')
            .orderBy('EndDate', descending: true)
            .where('Organization', isEqualTo: organizationId)
            .get();
    print(organizationId);
    return snapshot.docs
        .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print("Error getting activities by organization: $e");
  }
  return [];
}

Future<List<OrganizationModel>> getMyOrganizations() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot =
        await firestore
            .collection('organizations')
            .where(
              'Admins',
              arrayContains: FirebaseAuth.instance.currentUser?.uid,
            )
            .get();
    return snapshot.docs
        .map((doc) => OrganizationModel.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print("Error getting my organizations: $e");
  }
  return [];
}

Future<OrganizationModel?> getOrganizationsById(String organizationId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("organizations")
            .doc(organizationId)
            .get();
    return OrganizationModel.fromMap(snapshot.data()!, snapshot.id);
  } catch (e) {
    print("Error getting organization by ID: $e");
  }
  return null;
}
