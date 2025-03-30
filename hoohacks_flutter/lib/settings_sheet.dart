import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSheet extends StatefulWidget {
  final ScrollController scrollController;
  const SettingsSheet({super.key, required this.scrollController});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    getMapType();
    super.initState();
  }

  void getMapType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mapType = prefs.getString('mapType');
    if (mapType != null) {
      setState(() {
        _mapType = MapType.values.firstWhere(
          (MapType type) => type.toString() == mapType,
        );
      });
    }
  }

  void setMapType(MapType mapType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(mapType.toString());
    prefs.setString('mapType', mapType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Map Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.5), thickness: 1),
          for (MapType mapType in MapType.values)
            RadioListTile<MapType>(
              title: Text(mapType.toString().split('.').last),
              value: mapType,
              groupValue: _mapType,
              onChanged: (MapType? value) {
                setState(() {
                  _mapType = value!;
                  setMapType(value);
                });
              },
            ),
        ],
      ),
    );
  }
}
