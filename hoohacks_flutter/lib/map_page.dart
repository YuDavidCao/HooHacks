import 'dart:ui';

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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MapPage extends StatefulWidget {
  final ActivityModel? activityModel;
  const MapPage({super.key, this.activityModel});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late CameraPosition camera;

  Set<Marker> _markers = {};
  Map<Circle, CircleConfig> _circles = {};

  List<String> _categories = [];
  String distanceFilter = "none";

  LatLng _currentCameraPosition = uvaLatLng;
  LatLng yourLocation = uvaLatLng;

  double zoomLevel = 16;

  List<ActivityModel> _activities = [];

  MapType mapType = MapType.normal;

  bool bookMarked = false;

  late BitmapDescriptor yellowMarker;
  late BitmapDescriptor yellowOrangeMarker;
  late BitmapDescriptor orangeMarker;
  late BitmapDescriptor orangeRedMarker;
  late BitmapDescriptor redMarker;
  late BitmapDescriptor currentMarker;

  void setBookMarked(bool value) {
    setState(() {
      bookMarked = value;
      onFilterChanged();
    });
  }

  void onFilterChanged() async {
    _activities = await getFilteredActivities(
      _currentCameraPosition.longitude, // longitude,
      _currentCameraPosition.latitude, // latitude,
      _categories, // categories,
      distanceFilter, // distance,
      _searchController.text, // searchString,
      bookMarked, // bookMarkedOnly
    );

    setState(() {
      _markers =
          _activities.map((activity) {
            return Marker(
              markerId: MarkerId(activity.id!),
              position: LatLng(activity.latitude, activity.longitude),
              infoWindow: InfoWindow(title: activity.title),
              anchor: Offset(0.5, 0.5),
              icon: weightToMarker(activity.weight!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityPage(activityModel: activity),
                  ),
                );
              },
            );
          }).toSet();
      _markers.add(
        Marker(
          markerId: const MarkerId("current"),
          position: _currentCameraPosition,
          infoWindow: const InfoWindow(title: "Current Location"),
          anchor: const Offset(0.5, 0.5),
          icon: currentMarker,
        ),
      );
      Map<Circle, CircleConfig> newCircle = {};
      for (ActivityModel activity in _activities) {
        newCircle[Circle(
          circleId: CircleId(activity.id!),
          center: LatLng(activity.latitude, activity.longitude),
          radius: 0,
          fillColor: weightToColor(activity.weight!).withOpacity(0.5),
          strokeColor: Colors.transparent,
          strokeWidth: 0,
        )] = CircleConfig(
          radius:
              (400000000 *
                      activity.weight! *
                      (1 /
                          zoomLevel /
                          zoomLevel /
                          zoomLevel /
                          zoomLevel /
                          zoomLevel /
                          zoomLevel))
                  .round(),
          fillColor: weightToColor(activity.weight!).withOpacity(0.5),
        );
      }
      _circles = newCircle;
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

  BitmapDescriptor weightToMarker(double weight) {
    if (weight < 0.2) {
      return yellowMarker;
    } else if (weight < 0.4) {
      return yellowOrangeMarker;
    } else if (weight < 0.6) {
      return orangeMarker;
    } else if (weight < 0.8) {
      return orangeRedMarker;
    } else {
      return redMarker;
    }
  }

  Color weightToColor(double weight) {
    if (weight < 0.2) {
      return Colors.yellow;
    } else if (weight < 0.4) {
      return Colors.orange;
    } else if (weight < 0.6) {
      return Colors.deepOrange;
    } else if (weight < 0.8) {
      return Colors.red;
    } else {
      return Colors.redAccent;
    }
  }

  void initMarkers() async {
    List<Future<BitmapDescriptor>> futures = [
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/m1.png',
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/m2.png',
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/m3.png',
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/m4.png',
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/m5.png',
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/markers/current.png',
      ),
    ];

    final results = await Future.wait(futures);
    yellowMarker = results[0];
    yellowOrangeMarker = results[1];
    orangeMarker = results[2];
    orangeRedMarker = results[3];
    redMarker = results[4];
    currentMarker = results[5];

    onFilterChanged();
  }

  late final ActivityState activityState;

  void getMapType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mapType = prefs.getString('mapType');
    if (mapType != null) {
      setState(() {
        this.mapType = MapType.values.firstWhere(
          (MapType type) => type.toString() == mapType,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMapType();
    if (widget.activityModel != null) {
      _currentCameraPosition = LatLng(
        widget.activityModel!.latitude,
        widget.activityModel!.longitude,
      );
    }
    camera =
        widget.activityModel != null
            ? CameraPosition(
              target: LatLng(
                _currentCameraPosition.latitude,
                _currentCameraPosition.longitude,
              ),
              zoom: 16,
            )
            : CameraPosition(target: uvaLatLng, zoom: 16);
    initMarkers();
    onActivityChanged = () {
      onFilterChanged();
    };
    activityState = Provider.of<ActivityState>(context, listen: false);
    activityState.addListener(() {
      onActivityChanged();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createTutorial();
      SharedPreferences.getInstance().then((sharedPref) {
        if (!sharedPref.containsKey("MapPageFirstTimeInitialization")) {
          sharedPref.setBool("MapPageFirstTimeInitialization", false);
          Future.delayed(const Duration(seconds: 1), showTutorial);
        }
      });
    });
  }

  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey groundKey = GlobalKey();
  final GlobalKey updateLocationKey = GlobalKey();
  final GlobalKey myLocationKey = GlobalKey();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey filterKey = GlobalKey();

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "Ground",
          keyTarget: groundKey,
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
                      "Tap here to quickly return to the ground location and view the main campus area.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "updateLocation",
          keyTarget: updateLocationKey,
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
                      "Press here to update your current location. The map will smoothly center on your latest recorded position.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "AddTodoButton",
          keyTarget: myLocationKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Tap here to quickly retrieve your current location and navigate the map accordingly.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Search",
          keyTarget: searchKey,
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
                      "Enter keywords here to search for activities in your vicinity and discover events that match your interests.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "Filter",
          keyTarget: filterKey,
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
                      "Open the filter options to refine activities by categories, distance, and bookmarked selections, making it easier to find exactly what you're looking for.",
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
    });
  }

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
              bookMarked: bookMarked,
              setDistanceFilter: setDistanceFilter,
              onFilterChanged: onFilterChanged,
              setBookMarked: setBookMarked,
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
    activityState.removeListener(() {
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
            onCameraMove: (position) {
              _currentCameraPosition = position.target;
              setState(() {
                zoomLevel = position.zoom;
              });
            },
            mapType: mapType,
            initialCameraPosition: camera,
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
                  key: searchKey,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => {onFilterChanged()},
                  ),
                ),
                IconButton(
                  key: filterKey,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showFilterBottomSheet();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: null,
                  key: updateLocationKey,
                  onPressed: () {
                    setState(() {
                      yourLocation = LatLng(
                        _currentCameraPosition.latitude,
                        _currentCameraPosition.longitude,
                      );
                      onFilterChanged();
                    });
                  },
                  label: Text("Update Location"),
                  backgroundColor: ctaColor,
                ),
              ],
            ),
          ),
          Positioned(
            left: 15,
            bottom: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  key: groundKey,
                  heroTag: null,
                  onPressed: () {
                    _controller.future.then((controller) {
                      zoomLevel = 16;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: uvaLatLng, zoom: 16),
                        ),
                      );
                    });
                  },
                  child: const Icon(Icons.school),
                  backgroundColor: ctaColor,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: myLocationKey,
        onPressed: () {
          _determinePosition().then((position) {
            _controller.future.then((controller) {
              zoomLevel = 16;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 16,
                  ),
                ),
              );
            });
          });
        },
        backgroundColor: ctaColor,
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
