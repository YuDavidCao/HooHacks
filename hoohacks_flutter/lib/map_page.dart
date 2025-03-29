import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:hoohacks/create_activity_page.dart';
import 'package:hoohacks/filter_sheet.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';

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
  Set<Circle> _circles = {};

  List<String> _categories = [];
  String distanceFilter = "none";

  void onFilterChanged() {
    // ReQuery the database with the new filter.
  }

  void setDistanceFilter(String value) {
    setState(() {
      distanceFilter = value;
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

  @override
  void initState() {
    super.initState();

    // Load the custom marker icon.
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/markers/m1.png',
    ).then((icon) {
      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId('UVA'),
            position: const LatLng(38.033554, -78.507980),
            infoWindow: const InfoWindow(title: 'Google Plex'),
            icon: icon,
            onTap: () => print('UAV'),
            anchor: Offset(0.5, 0.5),
          ),
          Marker(
            markerId: MarkerId('UVA2'),
            position: const LatLng(38.133554, -78.517980),
            infoWindow: const InfoWindow(title: 'UVA2'),
            icon: icon,
            onTap: () => print('UVA2'),
            anchor: Offset(0.5, 0.5),
          ),
        };

        // Create initial circles with zero radius.
        _circles = {
          Circle(
            circleId: CircleId('ripple_UVA'),
            center: const LatLng(38.033554, -78.507980),
            radius: 0,
            fillColor: Colors.yellow.withOpacity(0.5),
            strokeColor: Colors.yellow,
            strokeWidth: 1,
          ),
          Circle(
            circleId: CircleId('ripple_UVA2'),
            center: const LatLng(38.133554, -78.517980),
            radius: 0,
            fillColor: Colors.yellow.withOpacity(0.5),
            strokeColor: Colors.yellow,
            strokeWidth: 1,
          ),
        };

        // Start the ripple animation.
        _animationController =
            AnimationController(
                vsync: this,
                duration: const Duration(seconds: 2),
              )
              ..addListener(_updateCircles)
              ..repeat();
      });
    });
  }

  void _updateCircles() {
    // Maximum radius (in meters) for the ripple.
    const double maxRadius = 100;
    final double currentRadius = _animationController.value * maxRadius;
    // Fade out circle as it expands.
    final double currentOpacity = (1 - _animationController.value) * 0.5;

    setState(() {
      _circles =
          _circles.map((circle) {
            return circle.copyWith(
              radiusParam: currentRadius,
              fillColorParam: Colors.yellow.withOpacity(currentOpacity),
            );
          }).toSet();
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
              setDistanceFilter: setDistanceFilter,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            circles: _circles,
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
                    // Implement search functionality here.
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
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
