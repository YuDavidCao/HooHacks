import 'package:flutter/material.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/states/activity_state.dart';
import 'package:provider/provider.dart';

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
                    Navigator.pushNamed(
                      context,
                      "/activity",
                      arguments: activity,
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
    );
  }
}
