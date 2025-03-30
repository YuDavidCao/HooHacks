import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/firebase/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddOrganizationPage extends StatefulWidget {
  const AddOrganizationPage({super.key});

  @override
  State<AddOrganizationPage> createState() => _AddOrganizationPageState();
}

class _AddOrganizationPageState extends State<AddOrganizationPage> {
  File? profilePicture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profilePicture = File(image.path);
      setState(() {});
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Organization')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            if (profilePicture != null)
              Padding(
                padding: middleWidgetPadding,
                child: Image.file(profilePicture!),
              ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name*",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _nameController.clear();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(
                  labelText: "Contact Email*",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _contactEmailController.clear();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _locationController.clear();
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final String name = _nameController.text;
                    final String description = _descriptionController.text;
                    final String email = _contactEmailController.text;
                    final String location = _locationController.text;

                    await createOrganization(
                      name,
                      description,
                      email,
                      location,
                      profilePicture,
                      context,
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}
