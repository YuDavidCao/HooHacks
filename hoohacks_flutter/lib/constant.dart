import 'package:flutter/material.dart';

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
];

const List<String> distanceFilters = [
  "none",
  "0.5 miles",
  "1 mile",
  "2 miles",
  "5 miles",
  "10 miles",
];
