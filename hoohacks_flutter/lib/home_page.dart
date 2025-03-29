import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/states/activity_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Consumer<ActivityState>(
        builder: (context, ActivityState activityState, child) {
          return ListView(
            children: [
              for (var activity in activityState.activities) ...[
                ListTile(
                  title: Text(activity.title),
                  subtitle: Text(activity.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ActivityPage(activityModel: activity),
                      ),
                    );
                  },
                ),
                Divider(),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "HomePage"),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     http
      //         .post(
      //           Uri.parse(
      //             "https://f826-199-111-224-44.ngrok-free.app/get-activity",
      //           ),
      //           body: jsonEncode({
      //             "Uid": "PYJrf3DWkVRcRhMmPAtgocAd79T2",
      //             "Longitude": "38.033554",
      //             "Latitude": "-78.507980",
      //           }),
      //           headers: {"Content-Type": "application/json"},
      //         )
      //         .then((response) {
      //           print(response.body);
      //         });
      //   },
      // ),
    );
  }
}
