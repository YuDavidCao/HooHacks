import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/organization/add_organization_page.dart';
import 'package:hoohacks/organization/organization_detail_page.dart';
import 'package:hoohacks/states/organization_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createTutorial();
      SharedPreferences.getInstance().then((sharedPref) {
        if (!sharedPref.containsKey(
          "OrganizationPagePageFirstTimeInitialization",
        )) {
          sharedPref.setBool(
            "OrganizationPagePageFirstTimeInitialization",
            false,
          );
          Future.delayed(const Duration(seconds: 1), showTutorial);
        }
      });
    });
  }

  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey bodyKey = GlobalKey();
  final GlobalKey addKey = GlobalKey();

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Body",
          keyTarget: bodyKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Organizations",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "This is where you can find all the organizations that are available to you. You can click on any organization to see more details.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.Circle,
          identify: "Add",
          keyTarget: addKey,
          radius: 50,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Add Organization",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "You can add an organization by clicking on this button.",
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Organizations')),
      body: Center(
        child: Consumer<OrganizationState>(
          builder: (context, OrganizationState organizationState, child) {
            return ListView(
              children: [
                SizedBox(key: bodyKey, height: 10),
                for (var organization in organizationState.organizations)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => OrganizationDetailPage(
                                organizationModel: organization,
                              ),
                        ),
                      );
                    },
                    child: Container(
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
                          if (organization.profilePicture != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Hero(
                                tag: organization.profilePicture!,
                                child: Image.network(
                                  organization.profilePicture!,
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        organization.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        organization.description,
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => OrganizationDetailPage(
                                              organizationModel: organization,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: addKey,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrganizationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(
        pageName: "OrganizationPage",
      ),
    );
  }
}
