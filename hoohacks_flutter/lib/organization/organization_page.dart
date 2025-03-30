import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/organization/add_organization_page.dart';
import 'package:hoohacks/organization/organization_detail_page.dart';
import 'package:hoohacks/states/organization_state.dart';
import 'package:provider/provider.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Organizations')),
      body: Center(
        child: Consumer<OrganizationState>(
          builder: (context, OrganizationState organizationState, child) {
            return ListView(
              children: [
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
                                Column(
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrganizationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "Organization"),
    );
  }
}
