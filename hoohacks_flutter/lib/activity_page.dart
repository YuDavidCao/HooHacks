import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/states/user_state.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  final ActivityModel activityModel;
  const ActivityPage({Key? key, required this.activityModel}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool isJoining = false;
  late bool upvoted;
  late bool downvoted;

  @override
  void initState() {
    isJoining = widget.activityModel.participants.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
    upvoted = Provider.of<UserState>(
      context,
      listen: false,
    ).userModel!.upvotedActivities.contains(widget.activityModel.id);
    downvoted = Provider.of<UserState>(
      context,
      listen: false,
    ).userModel!.downvotedActivities.contains(widget.activityModel.id);
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
          Padding(
            padding: middleWidgetPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        upvoted
                            ? cancelUpvoteActivity(widget.activityModel.id!)
                            : upvoteActivity(widget.activityModel.id!);
                        upvoted = !upvoted;
                      });
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: Text(upvoted ? "Cancel" : "Upvote"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        downvoted
                            ? cancelDownvoteActivity(widget.activityModel.id!)
                            : downvoteActivity(widget.activityModel.id!);
                        downvoted = !downvoted;
                      });
                    },
                    icon: const Icon(Icons.thumb_down),
                    label: Text(downvoted ? "Cancel" : "Downvote"),
                  ),
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
                child: const Text("Leave Activity"),
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
                child: const Text("Join Activity"),
              ),
            ),
          if (widget.activityModel.publisher ==
              FirebaseAuth.instance.currentUser!.uid)
            Padding(
              padding: middleWidgetPadding,
              child: ElevatedButton(
                onPressed: () {
                  deleteActivity(
                    widget.activityModel.id!,
                    widget.activityModel.imageUrl,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Delete Activity"),
              ),
            ),
        ],
      ),
    );
  }
}
