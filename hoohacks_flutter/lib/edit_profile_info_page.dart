import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/user_model.dart';

class EditProfileInfoPage extends StatefulWidget {
  const EditProfileInfoPage({super.key});

  @override
  State<EditProfileInfoPage> createState() => _EditProfileInfoPageState();
}

class _EditProfileInfoPageState extends State<EditProfileInfoPage> {
  final TextEditingController _usernameEditingController =
      TextEditingController();
  final TextEditingController _bioEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  @override
  void initState() {
    _usernameEditingController.text =
        FirebaseAuth.instance.currentUser?.displayName ?? "";
    _emailEditingController.text =
        FirebaseAuth.instance.currentUser?.email ?? "";
    getUserProfile();
    super.initState();
  }

  @override
  void dispose() {
    _usernameEditingController.dispose();
    _bioEditingController.dispose();
    _emailEditingController.dispose();
    super.dispose();
  }

  Future<void> getUserProfile() async {
    final UserModel userModel = await getUser(
      FirebaseAuth.instance.currentUser!.uid,
    );
    _bioEditingController.text = userModel.bio;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _usernameEditingController,
                decoration: InputDecoration(
                  labelText: "Username*",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _usernameEditingController.clear();
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _emailEditingController,
                decoration: InputDecoration(
                  labelText: "Email*",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _emailEditingController.clear();
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                maxLines: 5,
                controller: _bioEditingController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    String photoUrl =
                        FirebaseAuth.instance.currentUser!.photoURL!;
                    await FirebaseAuth.instance.currentUser?.updateEmail(
                      _emailEditingController.text,
                    );
                    await FirebaseAuth.instance.currentUser?.updateProfile(
                      displayName: _usernameEditingController.text,
                      photoURL: photoUrl,
                    );

                    updateUser(
                      _usernameEditingController.text,
                      _emailEditingController.text,
                      _bioEditingController.text,
                      context,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated successfully"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error updating profile")),
                    );
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
