import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/activity_model.dart';

class ActivityPage extends StatefulWidget {
  final ActivityModel activityModel;
  const ActivityPage({Key? key, required this.activityModel}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool isJoining = false;

  @override
  void initState() {
    isJoining = widget.activityModel.participants.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
    print(widget.activityModel.participants);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng activityLocation = LatLng(
      widget.activityModel.latitude,
      widget.activityModel.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityModel.title),
        backgroundColor: ctaColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (widget.activityModel.imageUrl != null)
            Padding(
              padding: middleWidgetPadding,
              child: Image.network(widget.activityModel.imageUrl!),
            ),
          Container(
            padding: middleWidgetPadding,
            width: double.infinity,
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: activityLocation,
                zoom: 16.5,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('location'),
                  position: activityLocation,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Text(
              widget.activityModel.description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                "${widget.activityModel.startDate.year}-${widget.activityModel.startDate.month}-${widget.activityModel.startDate.day} "
                "${widget.activityModel.startDate.hour}:${widget.activityModel.startDate.minute.toString().padLeft(2, '0')}",
              ),
              subtitle: const Text("Start Date & Time"),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                "${widget.activityModel.endDate.year}-${widget.activityModel.endDate.month}-${widget.activityModel.endDate.day} "
                "${widget.activityModel.endDate.hour}:${widget.activityModel.endDate.minute.toString().padLeft(2, '0')}",
              ),
              subtitle: const Text("End Date & Time"),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: ListTile(
              leading: const Icon(Icons.email),
              title: Text(widget.activityModel.contactEmail),
            ),
          ),
          if (widget.activityModel.categories.isNotEmpty)
            Padding(
              padding: middleWidgetPadding,
              child: Wrap(
                children: [
                  for (final category in widget.activityModel.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(label: Text(category)),
                    ),
                ],
              ),
            ),
          if (isJoining)
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    leaveActivity(widget.activityModel.id!, context);
                    isJoining = false;
                  });
                },
                child: Text("Leave Activity"),
              ),
            ),
          if (!isJoining)
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    joinActivity(widget.activityModel.id!, context);
                    isJoining = true;
                  });
                },
                child: Text("Join Activity"),
              ),
            ),
        ],
      ),
    );
  }
}
