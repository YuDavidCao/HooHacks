import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/models/organization_model.dart';
import 'package:hoohacks/models/user_model.dart';

class OrganizationDetailPage extends StatefulWidget {
  final OrganizationModel organizationModel;
  const OrganizationDetailPage({super.key, required this.organizationModel});

  @override
  State<OrganizationDetailPage> createState() => _OrganizationDetailPageState();
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  late bool joined;
  late bool isAdmin;

  @override
  void initState() {
    joined = widget.organizationModel.members.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
    isAdmin = widget.organizationModel.admins.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organizationModel.name)),
      body: ListView(
        children: [
          if (widget.organizationModel.profilePicture != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.organizationModel.profilePicture!,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.organizationModel.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.organizationModel.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          if (isAdmin)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: middleWidgetPadding,
                  child: Text(
                    'Members',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.organizationModel.members.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<UserModel>(
                        future: getUser(
                          widget.organizationModel.members[index],
                        ),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<UserModel> snapshot,
                        ) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Container(
                              padding: middleWidgetPadding,
                              margin: middleWidgetPadding,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(snapshot.data!.name),
                                      ),
                                    ],
                                  ),
                                  Text(snapshot.data!.email),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Members: ${widget.organizationModel.members.length}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          Padding(
            padding: middleWidgetPadding,
            child: Text(
              'Admins:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.organizationModel.admins.length,
              itemBuilder: (context, index) {
                return FutureBuilder<UserModel>(
                  future: getUser(widget.organizationModel.admins[index]),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<UserModel> snapshot,
                  ) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        padding: middleWidgetPadding,
                        margin: middleWidgetPadding,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(snapshot.data!.name),
                                ),
                              ],
                            ),
                            Text(snapshot.data!.email),
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
                );
              },
            ),
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Text(
              'Activities:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
            child: FutureBuilder(
              future: getActivitiesByOrganization(widget.organizationModel.id!),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ActivityModel>> snapshot,
              ) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ActivityPage(
                                    activityModel: snapshot.data![index],
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: middleWidgetPadding,
                          margin: middleWidgetPadding,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ctaColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data![index].title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                snapshot.data![index].description,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
          ),
        ],
      ),
      floatingActionButton:
          (!widget.organizationModel.admins.contains(
                FirebaseAuth.instance.currentUser!.uid,
              ))
              ? FloatingActionButton(
                onPressed: () {
                  if (joined) {
                    leaveOrganization(widget.organizationModel.id!, context);
                    setState(() {
                      joined = false;
                    });
                  } else {
                    joinOrganization(widget.organizationModel.id!, context);
                    setState(() {
                      joined = true;
                    });
                  }
                },
                child:
                    joined
                        ? const Icon(Icons.exit_to_app)
                        : const Icon(Icons.add),
              )
              : FloatingActionButton(
                onPressed: () {
                  deleteOrganization(widget.organizationModel, context);
                  Navigator.pop(context);
                },
                child: Icon(Icons.delete),
              ),
    );
  }
}
