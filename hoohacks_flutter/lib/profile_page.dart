import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/authentication_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/edit_profile_info_page.dart';
import 'package:hoohacks/firebase/firebase_auth.dart';
import 'package:hoohacks/firebase/firebase_storage.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/settings_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController bioEditingController = TextEditingController();

  File? profilePicture;

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profilePicture = File(image.path);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(
        await uploadProfilePicture(profilePicture!, context),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Stack(
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage:
                      profilePicture != null
                          ? FileImage(profilePicture!)
                          : FirebaseAuth.instance.currentUser!.photoURL == null
                          ? AssetImage('assets/images/profile.png')
                          : NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                          ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      pickImage();
                    },
                    shape: CircleBorder(),
                    backgroundColor: ctaColor,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              FirebaseAuth.instance.currentUser!.displayName ?? "User",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              margin: middleWidgetPadding,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileInfoPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person),
                              SizedBox(width: 10),
                              Text("Profile Info"),
                            ],
                          ),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.6,
                            minChildSize: 0.2,
                            maxChildSize: 0.6,
                            builder: ((context, scrollController) {
                              return SettingsSheet(
                                scrollController: scrollController,
                              );
                            }),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 10),
                              Text("Map Settings"),
                            ],
                          ),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: middleWidgetPadding,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthenticationPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 10),
                              Text("Log Out"),
                            ],
                          ),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      bool confirmDelete = false;
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Account"),
                            content: const Text(
                              "Are you sure you want to delete your account?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  confirmDelete = true;
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () {
                                  confirmDelete = false;
                                  Navigator.of(context).pop();
                                },
                                child: const Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmDelete) {
                        deleteAccount();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthenticationPage(),
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Delete Account",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "ProfilePage"),
    );
  }
}
