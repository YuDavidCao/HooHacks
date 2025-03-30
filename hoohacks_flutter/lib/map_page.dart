import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/constant.dart';
import 'dart:async';

import 'package:hoohacks/create_activity_page.dart';
import 'package:hoohacks/filter_sheet.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/firebase/flask_endpint.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/models/activity_model.dart';
import 'package:hoohacks/states/activity_state.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(38.033554, -78.507980),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};
  Map<Circle, CircleConfig> _circles = {};

  List<String> _categories = [];
  String distanceFilter = "none";

  LatLng _currentCameraPosition = const LatLng(38.033554, -78.507980);

  List<ActivityModel> _activities = [];

  void onFilterChanged() async {
    _activities = await getFilteredActivities(
      _currentCameraPosition.longitude, // longitude,
      _currentCameraPosition.latitude, // latitude,
      _categories, // categories,
      distanceFilter, // distance,
      _searchController.text, // searchString,
    );
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/markers/m1.png',
    ).then((icon) {
      setState(() {
        _markers =
            _activities.map((activity) {
              return Marker(
                markerId: MarkerId(activity.id!),
                position: LatLng(activity.latitude, activity.longitude),
                infoWindow: InfoWindow(title: activity.title),
                anchor: Offset(0.5, 0.5),
                icon: icon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ActivityPage(activityModel: activity),
                    ),
                  );
                },
              );
            }).toSet();
        for (ActivityModel activity in _activities) {
          _circles[Circle(
            circleId: CircleId(activity.id!),
            center: LatLng(activity.latitude, activity.longitude),
            radius: 0,
            fillColor: Colors.yellow.withOpacity(0.5),
            strokeColor: Colors.transparent,
            strokeWidth: 0,
          )] = CircleConfig(
            radius: 10,
            fillColor: Colors.yellow.withOpacity(0.5),
          );
        }
        if (!init) {
          _animationController =
              AnimationController(
                  vsync: this,
                  duration: const Duration(seconds: 2),
                )
                ..addListener(_updateCircles)
                ..repeat();
        }
        init = true;
      });
    });
  }

  bool init = false;

  void setDistanceFilter(String value) {
    setState(() {
      distanceFilter = value;
      onFilterChanged();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  late Function onActivityChanged;

  @override
  void initState() {
    super.initState();
    onFilterChanged();
    onActivityChanged = () {
      onFilterChanged();
    };
    Provider.of<ActivityState>(context, listen: false).addListener(() {
      onActivityChanged();
    });
  }

  void _updateCircles() {
    setState(() {
      Map<Circle, CircleConfig> newCircles = {};
      for (Circle circle in _circles.keys) {
        final double maxRadius = _circles[circle]!.radius.toDouble();
        final double currentRadius = _animationController.value * maxRadius;
        final double currentOpacity = (1 - _animationController.value) * 0.5;
        Circle newCircle = circle.copyWith(
          radiusParam: currentRadius,
          fillColorParam: _circles[circle]!.fillColor.withOpacity(
            currentOpacity,
          ),
        );
        newCircles[newCircle] = _circles[circle]!;
      }
      _circles = newCircles;
      // for (Circle circle in _circles.keys) {
      //   _circles[circle] = _circles[circle]!.copyWith(
      //     radius: currentRadius.toInt(),
      //     fillColor: _circles[circle]!.fillColor.withOpacity(currentOpacity),
      //   );
      // }
      // _circles =
      //     _circles.entries.map((MapEntry<Circle, CircleConfig> entry) {
      //       return entry.key.copyWith(
      //         radiusParam: entry.value.radius,
      //         fillColorParam: entry.value.fillColor.withOpacity(currentOpacity),
      //       );
      //     }).toSet();
    });
  }

  //   setState(() {
  //   _circles =
  //       _circles.map((circle) {
  //         return circle.copyWith(
  //           radiusParam: currentRadius,
  //           fillColorParam: Colors.yellow.withOpacity(currentOpacity),
  //         );
  //       }).toSet();
  // });

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: ((context, scrollController) {
            return FilterSheet(
              scrollController: scrollController,
              categories: _categories,
              distanceFilter: distanceFilter,
              setDistanceFilter: setDistanceFilter,
              onFilterChanged: onFilterChanged,
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _markers.clear();
    _circles.clear();
    _controller.future.then((controller) {
      controller.dispose();
    });
    _searchController.dispose();
    Provider.of<ActivityState>(context, listen: false).removeListener(() {
      onActivityChanged();
    });
    // _listener.ca
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onCameraMove:
                (position) => _currentCameraPosition = position.target,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            circles: _circles.keys.toSet(),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
            onLongPress: (LatLng position) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateActivityPage(location: position),
                ),
              );
            },
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    onFilterChanged();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => {
                      onFilterChanged(),
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showFilterBottomSheet();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _determinePosition().then((position) {
            _controller.future.then((controller) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 14.4746,
                  ),
                ),
              );
            });
          });
        },
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: GlobalBottomNavigationBar(pageName: "MapPage"),
    );
  }
}

class CircleConfig {
  final int radius;
  final Color fillColor;
  CircleConfig({required this.radius, required this.fillColor});
}
