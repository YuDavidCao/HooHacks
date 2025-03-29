import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/edit_profile_info_page.dart';
import 'package:hoohacks/firebase/firebase_auth.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController bioEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(height: 20),
            const Text("HooHacks", style: TextStyle(fontSize: 20)),
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
                              Icon(Icons.info),
                              SizedBox(width: 10),
                              Text("Bio"),
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
