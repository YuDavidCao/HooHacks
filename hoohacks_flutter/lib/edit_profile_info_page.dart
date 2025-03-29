import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';

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
  void dispose() {
    _usernameEditingController.dispose();
    _bioEditingController.dispose();
    _emailEditingController.dispose();
    super.dispose();
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete),
                  ),
                ),
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
