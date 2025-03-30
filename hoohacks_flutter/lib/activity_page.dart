import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/map_page.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/states/user_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  final ActivityModel activityModel;
  const ActivityPage({Key? key, required this.activityModel}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool isJoining = false;
  late bool saved;
  late bool upvoted;
  late bool downvoted;

  @override
  void initState() {
    isJoining = widget.activityModel.participants.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
    saved = Provider.of<UserState>(
      context,
      listen: false,
    ).userModel!.savedActivities.contains(widget.activityModel.id);
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
              child: Hero(
                tag: widget.activityModel.imageUrl!,
                child: Image.network(widget.activityModel.imageUrl!),
              ),
            ),
          Stack(
            children: [
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
              Positioned(
                bottom: 15,
                right: 25,
                child: FloatingActionButton.small(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                MapPage(activityModel: widget.activityModel),
                      ),
                    );
                  },
                  child: Icon(Icons.map),
                ),
              ),
            ],
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.activityModel.description,
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${widget.activityModel.participants.length} participants",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.people, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.thumb_up, size: 20, color: ctaColor),
                    Text(
                      "${widget.activityModel.upvotes} upvotes",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.thumb_down_outlined, size: 20, color: ctaColor),
                    Text(
                      "${widget.activityModel.downvotes} downvotes",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.activityModel.publisher ==
              FirebaseAuth.instance.currentUser!.uid)
            Padding(
              padding: middleWidgetPadding,
              child: Text("Participants", style: TextStyle(fontSize: 16)),
            ),
          if (widget.activityModel.publisher ==
              FirebaseAuth.instance.currentUser!.uid)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.activityModel.participants.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: middleWidgetPadding,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: getUserInfo(
                        widget.activityModel.participants[index],
                      ),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot,
                      ) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.person),
                                Text(snapshot.data!['Username']),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: middleWidgetPadding,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.activityModel.startDate.isBefore(DateTime.now())
                            ? Icons.event_busy
                            : Icons.event_available,
                        color:
                            widget.activityModel.startDate.isBefore(
                                  DateTime.now(),
                                )
                                ? Colors.grey
                                : Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(
                            widget.activityModel.startDate,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                widget.activityModel.startDate.isBefore(
                                      DateTime.now(),
                                    )
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Start Date & Time",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.activityModel.startDate.isBefore(
                                DateTime.now(),
                              )
                              ? Colors.grey
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.activityModel.endDate.isBefore(DateTime.now())
                            ? Icons.event_busy
                            : Icons.event_available,
                        color:
                            widget.activityModel.endDate.isBefore(
                                  DateTime.now(),
                                )
                                ? Colors.grey
                                : Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(
                            widget.activityModel.endDate,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                widget.activityModel.endDate.isBefore(
                                      DateTime.now(),
                                    )
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "End Date & Time",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.activityModel.endDate.isBefore(DateTime.now())
                              ? Colors.grey
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Row(
              children: [
                Icon(Icons.email),
                const SizedBox(width: 10),
                Text(widget.activityModel.contactEmail),
              ],
            ),
          ),
          if (widget.activityModel.locationName != null)
            Padding(
              padding: middleWidgetPadding,
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  const SizedBox(width: 10),
                  Text(widget.activityModel.locationName!),
                ],
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
          if (!isJoining &&
              widget.activityModel.endDate.isAfter(DateTime.now()))
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            saved
                ? unsaveActivity(widget.activityModel.id!)
                : saveActivity(widget.activityModel.id!);
            saved = !saved;
          });
        },
        backgroundColor: saved ? ctaColor : Colors.grey[50],
        child: saved ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
      ),
    );
  }
}
