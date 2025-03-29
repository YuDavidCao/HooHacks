import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';

class CreateActivityPage extends StatefulWidget {
  final LatLng location;
  const CreateActivityPage({super.key, required this.location});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _startDateTimeController =
      TextEditingController();
  final TextEditingController _endDateTimeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  final List<String> _categories = [];

  @override
  void initState() {
    _startDateTimeController.text =
        "${_startDate.year}-${_startDate.month}-${_startDate.day} ${_startDate.hour}:${_startDate.minute}";
    _endDateTimeController.text =
        "${_endDate.year}-${_endDate.month}-${_endDate.day} ${_endDate.hour}:${_endDate.minute}";
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        backgroundColor: const Color.fromARGB(255, 255, 64, 0),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              padding: middleWidgetPadding,
              width: double.infinity,
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.location,
                  zoom: 16.5,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('location'),
                    position: widget.location,
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: false,
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title*",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _titleController.clear();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
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
                      _titleController.clear();
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
                controller: _startDateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Start Date & Time",
                  border: const OutlineInputBorder(),
                  suffixIcon: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _startDate) {
                            setState(() {
                              _startDate = picked;
                              _startDateTimeController.text =
                                  "${_startDate.year}-${_startDate.month}-${_startDate.day} ${_startDate.hour}:${_startDate.minute}";
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_startDate),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = DateTime(
                                _startDate.year,
                                _startDate.month,
                                _startDate.day,
                                picked.hour,
                                picked.minute,
                              );
                              _startDateTimeController.text =
                                  "${_startDate.year}-${_startDate.month}-${_startDate.day} ${_startDate.hour}:${_startDate.minute}";
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: TextFormField(
                controller: _endDateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "End Date & Time",
                  border: const OutlineInputBorder(),
                  suffixIcon: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _endDate) {
                            setState(() {
                              _endDate = picked;
                              _endDateTimeController.text =
                                  "${_endDate.year}-${_endDate.month}-${_endDate.day} ${_endDate.hour}:${_endDate.minute}";
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_endDate),
                          );
                          if (picked != null) {
                            setState(() {
                              _endDate = DateTime(
                                _endDate.year,
                                _endDate.month,
                                _endDate.day,
                                picked.hour,
                                picked.minute,
                              );
                              _endDateTimeController.text =
                                  "${_endDate.year}-${_endDate.month}-${_endDate.day} ${_endDate.hour}:${_endDate.minute}";
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an end date';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: middleWidgetPadding,
              child: Wrap(
                children: [
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _categories.contains(category),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _categories.add(category);
                            } else {
                              _categories.remove(category);
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            bool successful = await addActivity(
              _titleController.text,
              _descriptionController.text,
              _categories.isNotEmpty ? _categories.first : '',
              widget.location.latitude,
              widget.location.longitude,
              _startDate,
              _endDate,
              _categories,
              _contactEmailController.text,
            );
            if (successful) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity created successfully!')),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create activity.')),
              );
            }
          }
        },
        backgroundColor: const Color.fromARGB(255, 229, 114, 0),
        child: const Icon(Icons.check),
      ),
    );
  }
}
