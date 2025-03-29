import 'package:flutter/material.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "HomePage"),
    );
  }
}
