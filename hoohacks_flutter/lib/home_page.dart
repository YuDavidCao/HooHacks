import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/states/activity_state.dart';
import 'package:hoohacks/states/user_state.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createTutorial();
      SharedPreferences.getInstance().then((sharedPref) {
        if (!sharedPref.containsKey("HomePagePageFirstTimeInitialization")) {
          sharedPref.setBool("HomePagePageFirstTimeInitialization", false);
          Future.delayed(const Duration(seconds: 1), showTutorial);
        }
      });
    });
  }

  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey upComingKey = GlobalKey();
  final GlobalKey allActivityKey = GlobalKey();
  final GlobalKey byMeKey = GlobalKey();
  final GlobalKey savedKey = GlobalKey();

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "Upcoming",
          keyTarget: upComingKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Upcoming activities: Check out the events you're scheduled to attend soon. Tap on an activity to learn more about its time, venue, and additional details.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "All Activity",
          keyTarget: allActivityKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "All activities: Browse through the complete list of available events. Discover various opportunities and choose the ones that match your interests.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "By Me",
          keyTarget: byMeKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "By Me: View and manage the activities you have created. This section helps you keep track of your own events and any updates you make to them.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "Saved",
          keyTarget: savedKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Saved activities: Easily access the events you have bookmarked. This tab stores your saved activities for quick reference whenever needed.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
      colorShadow: Theme.of(context).colorScheme.primary,
      textSkip: "SKIP",
      textStyleSkip: Theme.of(context).textTheme.titleLarge!,
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
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
              Tab(
                key: upComingKey,
                icon: Icon(Icons.calendar_month),
                text: 'Upcoming',
              ),
              Tab(
                key: allActivityKey,
                icon: Icon(Icons.celebration),
                text: 'All Activities',
              ),
              Tab(key: byMeKey, icon: Icon(Icons.person), text: 'By Me'),
              Tab(key: savedKey, icon: Icon(Icons.bookmark), text: 'Saved'),
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
                } else if (_tabController.index == 3) {
                  activities =
                      activities
                          .where(
                            (activity) => Provider.of<UserState>(
                              context,
                              listen: false,
                            ).userModel!.savedActivities.contains(activity.id),
                          )
                          .toList();
                }

                print(activities);

                return activities.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 300,
                            width: 300,
                            child: Lottie.asset(
                              'assets/animations/animation.json',
                            ),
                          ),
                          Text(
                            "No activities found",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          children: List.generate(activities.length, (index) {
                            final activity = activities[index];
                            bool saved = Provider.of<UserState>(
                              context,
                              listen: false,
                            ).userModel!.savedActivities.contains(activity.id);
                            return GestureDetector(
                              key: ValueKey(activity.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ActivityPage(
                                          activityModel: activity,
                                        ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (activity.imageUrl != null)
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                            child: Hero(
                                              tag: activity.imageUrl!,
                                              child: Image.network(
                                                activity.imageUrl!,
                                                fit: BoxFit.cover,
                                                height: 100,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                activity.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                activity.description,
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Wrap(
                                                runSpacing: -10,
                                                children: [
                                                  for (var category
                                                      in activity
                                                          .categories) ...[
                                                    Chip(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            3,
                                                          ),
                                                      label: Text(
                                                        category,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      labelPadding:
                                                          const EdgeInsets.all(
                                                            0,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: SavedButton(
                                      activity: activity,
                                      saved: saved,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "HomePage"),
      // floatingActionButton: Wrap(
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {
      //         http
      //             .get(
      //               Uri.parse("${baseUrl}/get-documents"),
      //               headers: {"Content-Type": "application/json"},
      //             )
      //             .then((response) {
      //               print(response.body);
      //             });
      //       },
      //       child: Icon(Icons.get_app),
      //     ),
      //     const SizedBox(width: 10),
      //     FloatingActionButton(
      //       onPressed: () {
      //         http
      //             .post(
      //               Uri.parse("${baseUrl}/get-relevant-activities"),
      //               body: jsonEncode({
      //                 "EndDate": DateTime.now().microsecondsSinceEpoch,
      //                 "Interests": "I want to eat apple!",
      //               }),
      //               headers: {"Content-Type": "application/json"},
      //             )
      //             .then((response) {
      //               print(response.body);
      //             });
      //       },
      //       child: Icon(Icons.add),
      //     ),
      //   ],
      // ),
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

class SavedButton extends StatefulWidget {
  final ActivityModel activity;
  final bool saved;
  const SavedButton({super.key, required this.activity, required this.saved});

  @override
  State<SavedButton> createState() => _SavedButtonState();
}

class _SavedButtonState extends State<SavedButton> {
  late bool saved;

  @override
  void initState() {
    saved = widget.saved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: () {
        setState(() {
          saved
              ? unsaveActivity(widget.activity.id!)
              : saveActivity(widget.activity.id!);
          saved = !saved;
        });
      },
      backgroundColor: saved ? ctaColor : Colors.grey[200],
      child: saved ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
    );
  }
}
