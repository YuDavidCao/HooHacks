import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/authentication_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/edit_profile_info_page.dart';
import 'package:hoohacks/firebase/firebase_auth.dart';
import 'package:hoohacks/firebase/firebase_storage.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/settings_sheet.dart';
import 'package:hoohacks/states/theme_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createTutorial();
      SharedPreferences.getInstance().then((sharedPref) {
        if (!sharedPref.containsKey("ProfilePagePageFirstTimeInitialization")) {
          sharedPref.setBool("ProfilePagePageFirstTimeInitialization", false);
          Future.delayed(const Duration(seconds: 1), showTutorial);
        }
      });
    });
  }

  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey profileInfoKey = GlobalKey();
  final GlobalKey mapSettingKey = GlobalKey();
  final GlobalKey accountKey = GlobalKey();

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Profile",
          keyTarget: profileInfoKey,
          enableOverlayTab: true,
          alignSkip: Alignment.topRight,

          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Profile Info",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "You can edit your profile info by clicking on this button.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Map",
          keyTarget: mapSettingKey,
          enableOverlayTab: true,
          alignSkip: Alignment.topRight,

          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Map Settings",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "You can edit your map settings by clicking on this button.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Account",
          keyTarget: accountKey,
          enableOverlayTab: true,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Account",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "You can log out or delete your account by clicking on this button.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
      colorShadow: Theme.of(context).colorScheme.primary,
      textSkip: "SKIP",
      textStyleSkip: Theme.of(context).textTheme.titleLarge!,
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Stack(
              children: [
                CircleAvatar(
                  radius: 100,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      key: profileInfoKey,
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
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      key: mapSettingKey,
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
                                Icon(Icons.map_outlined),
                                SizedBox(width: 10),
                                Text("Map Settings"),
                              ],
                            ),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Divider(color: Theme.of(context).colorScheme.primary),
                  // GestureDetector(
                  //   behavior: HitTestBehavior.opaque,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const EditProfileInfoPage(),
                  //       ),
                  //     );
                  //   },
                  //   child: Consumer<ThemeProvider>(
                  //     builder: (context, ThemeProvider themeProvider, child) {
                  //       return Padding(
                  //         padding: EdgeInsets.symmetric(
                  //           vertical: 0,
                  //           horizontal: 2),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 themeProvider.themeMode == ThemeMode.dark
                  //                     ? Icon(Icons.light_mode)
                  //                     : Icon(Icons.dark_mode),
                  //                 SizedBox(width: 10),
                  //                 Text("Dark Mode"),
                  //               ],
                  //             ),
                  //             Transform.scale(
                  //               scale: 0.8,
                  //               child: Switch(
                  //                 padding: EdgeInsets.zero,
                  //                 value:
                  //                     themeProvider.themeMode == ThemeMode.dark,
                  //                 onChanged: (value) {
                  //                   themeProvider.toggleTheme(value);
                  //                 },
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              key: accountKey,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        signOut();
                        SharedPreferences.getInstance().then((sharedPref) {
                          sharedPref.clear();
                        });
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
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
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
