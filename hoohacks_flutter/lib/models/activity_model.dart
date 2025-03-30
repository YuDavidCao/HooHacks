import 'package:intl/intl.dart';

class ActivityModel {
  final String? id;
  final String publisher;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime startDate;
  final DateTime endDate;
  final double latitude;
  final double longitude;
  final String? organization;
  final List<String> categories;
  final List<String> participants;
  final int? limit;
  final String contactEmail;
  final int upvotes;
  final int downvotes;
  final bool organizationOnly;
  final String? imageUrl;
  final double? weight;

  ActivityModel({
    this.id,
    required this.publisher,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.latitude,
    required this.longitude,
    this.organization,
    required this.categories,
    required this.participants,
    this.limit,
    required this.contactEmail,
    required this.upvotes,
    required this.downvotes,
    required this.organizationOnly,
    this.imageUrl,
    this.weight
  });

  Map<String, dynamic> toMap() {
    return {
      'Publisher': publisher,
      'Title': title,
      'Description': description,
      'CreatedDate': createdDate,
      'StartDate': startDate,
      'EndDate': endDate,
      'Latitude': latitude,
      'Longitude': longitude,
      'Organization': organization,
      'Categories': categories,
      'Participants': participants,
      'Limit': limit,
      'ContactEmail': contactEmail,
      'Upvotes': upvotes,
      'Downvotes': downvotes,
      'OrganizationOnly': organizationOnly,
      'ImageUrl': imageUrl,
    };
  }

  static ActivityModel fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      publisher: map['Publisher'],
      title: map['Title'],
      description: map['Description'],
      createdDate: map['CreatedDate'].toDate(),
      startDate: map['StartDate'].toDate(),
      endDate: map['EndDate'].toDate(),
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      organization: map['Organization'],
      categories: List<String>.from(map['Categories']),
      participants: List<String>.from(map['Participants']),
      limit: map['Limit'],
      contactEmail: map['ContactEmail'],
      upvotes: map['Upvotes'],
      downvotes: map['Downvotes'],
      organizationOnly: map['OrganizationOnly'],
      imageUrl: map['ImageUrl'],
    );
  }

  static ActivityModel fromFlask(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      publisher: map['Publisher'],
      title: map['Title'],
      description: map['Description'],
      createdDate: DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      ).parseUtc(map['CreatedDate']),
      startDate: DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      ).parseUtc(map['StartDate']),
      endDate: DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      ).parseUtc(map['EndDate']),
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      organization: map['Organization'],
      categories: List<String>.from(map['Categories']),
      participants: List<String>.from(map['Participants']),
      limit: map['Limit'],
      contactEmail: map['ContactEmail'],
      upvotes: map['Upvotes'],
      downvotes: map['Downvotes'],
      organizationOnly: map['OrganizationOnly'],
      imageUrl: map['ImageUrl'],
      weight: map['Weight'],
    );
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, publisher: $publisher, title: $title, description: $description, createdDate: $createdDate, startDate: $startDate, endDate: $endDate, latitude: $latitude, longitude: $longitude, organization: $organization, categories: $categories, participants: $participants, limit: $limit, contactEmail: $contactEmail, upvotes: $upvotes, downvotes: $downvotes, organizationOnly: $organizationOnly, imageUrl: $imageUrl)';
  }
}
