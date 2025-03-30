import 'package:flutter/material.dart';
import 'package:hoohacks/interest_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/home_page.dart';
import 'package:hoohacks/map_page.dart';
import 'package:hoohacks/organization/organization_page.dart';
import 'package:hoohacks/profile_page.dart';

class GlobalBottomNavigationBar extends StatelessWidget {
  final String pageName;

  const GlobalBottomNavigationBar({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: pageName == "HomePage" ? ctaColor : Colors.black,
            ),
            onPressed: () {
              if (pageName != "HomePage") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.map,
              color: pageName == "MapPage" ? ctaColor : Colors.black,
            ),

            onPressed: () {
              if (pageName != "MapPage") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.interests,
              color: pageName == "InterestPage" ? ctaColor : Colors.black,
            ),
            onPressed: () {
              if (pageName != "InterestPage") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InterestPage()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.domain,
              color: pageName == "OrganizationPage" ? ctaColor : Colors.black,
            ),
            onPressed: () {
              if (pageName != "OrganizationPage") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrganizationPage()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: pageName == "ProfilePage" ? ctaColor : Colors.black,
            ),
            onPressed: () {
              if (pageName != "ProfilePage") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
