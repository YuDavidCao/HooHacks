import 'package:flutter/material.dart';
import 'package:hoohacks/home_page.dart';
import 'package:hoohacks/map_page.dart';
import 'package:hoohacks/profile_page.dart';

class GlobalBottomNavigationBar extends StatelessWidget {
  final String pageName;

  const GlobalBottomNavigationBar({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
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
            icon: const Icon(Icons.map),
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
            icon: const Icon(Icons.person),
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
