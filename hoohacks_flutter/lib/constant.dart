import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

RegExp emailRegex = RegExp(r'^[a-zA-Z0-9]{5,6}@virginia\.edu$');

const middleWidgetPadding = EdgeInsets.fromLTRB(20, 10, 20, 10);

const List<String> categories = [
  "Academic",
  "Admissions",
  "Athletics",
  "Ceremony",
  "Conference",
  "Exhibit",
  "Information Session",
  "Lectures & Seminars",
  "Meeting",
  "Performance",
  "Screening",
  "Special Event",
  "Student Activity",
  "Workshop",
  "1st Year",
  "2nd Year",
  "3rd Year",
  "4th Year",
  "Graduate",
];

const List<String> distanceFilters = [
  "none",
  "0.5 miles",
  "1 mile",
  "2 miles",
  "5 miles",
  "10 miles",
];

const Color ctaColor = Colors.orange;

const String baseUrl = "https://live-fish-mighty.ngrok-free.app/";

const LatLng uvaLatLng = LatLng(38.033554, -78.507980);