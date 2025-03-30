import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/states/activity_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              const Tab(icon: Icon(Icons.calendar_month), text: 'Upcoming'),
              const Tab(icon: Icon(Icons.celebration), text: 'All Activities'),
              const Tab(icon: Icon(Icons.create), text: 'Created'),
            ],
          ),
          Flexible(
            child: Consumer<ActivityState>(
              builder: (context, ActivityState activityState, child) {
                List<ActivityModel> activities = activityState.activities;

                if (_tabController.index == 0) {
                  activities =
                      activities
                          .where(
                            (activity) =>
                                activity.endDate.isAfter(DateTime.now()) &&
                                activity.participants.contains(
                                  FirebaseAuth.instance.currentUser!.uid,
                                ),
                          )
                          .toList();
                } else if (_tabController.index == 2) {
                  activities =
                      activities
                          .where(
                            (activity) =>
                                activity.publisher ==
                                FirebaseAuth.instance.currentUser!.uid,
                          )
                          .toList();
                }

                print(activities);

                return ListView(
                  children: [
                    for (var activity in activities) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ActivityPage(activityModel: activity),
                            ),
                          );
                        },
                        child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(activity.description),
                              Wrap(
                                children: [
                                  for (var categories
                                      in activity.categories) ...[
                                    Chip(label: Text(categories)),
                                    SizedBox(width: 5),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "HomePage"),
      floatingActionButton: Wrap(
        children: [
          FloatingActionButton(
            onPressed: () {
              http
                  .get(
                    Uri.parse("${baseUrl}/get-documents"),
                    headers: {"Content-Type": "application/json"},
                  )
                  .then((response) {
                    print(response.body);
                  });
            },
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              http
                  .post(
                    Uri.parse("${baseUrl}/get-documents"),
                    headers: {"Content-Type": "application/json"},
                  )
                  .then((response) {
                    print(response.body);
                  });
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // List<ActivityModel> activities = await getActivities();
      //     // log(activities.toString());
      //     // http
      //     //     .post(
      //     //       Uri.parse(
      //     //         "https://b5d8-199-111-224-44.ngrok-free.app/get-activity",
      //     //       ),
      //     //       body: jsonEncode({
      //     //         "Uid": "PYJrf3DWkVRcRhMmPAtgocAd79T2",
      //     //         "Longitude": "38.033554",
      //     //         "Latitude": "-78.507980",
      //     //         "Categories": ["1st Year", "Lectures & Seminars"],
      //     //         "Distances": 1,
      //     //         "SearchString": "",
      //     //       }),
      //     //       headers: {"Content-Type": "application/json"},
      //     //     )
      //     //     .then((response) {
      //     //       log(response.body);
      //     //     });
      //     http
      //         .post(
      //           Uri.parse("${baseUrl}/get-activity"),
      //           body: jsonEncode({
      //             "Uid": "PYJrf3DWkVRcRhMmPAtgocAd79T2",
      //             "Longitude": "-78.507980",
      //             "Latitude": "38.033554",
      //             "Categories": [],
      //             "Distances": "0.1",
      //             "SearchString": "",
      //           }),
      //           headers: {"Content-Type": "application/json"},
      //         )
      //         .then((response) {
      //           final a =
      //               (jsonDecode(response.body)["activities"] as List)
      //                   .map(
      //                     (e) => ActivityModel.fromFlask(
      //                       e as Map<String, dynamic>,
      //                       e['Id'],
      //                     ),
      //                   )
      //                   .toList();
      //           print(a.length);
      //           log(a.toString());
      //         });
      //   },
      // ),
    );
  }
}
