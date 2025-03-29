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
  });

  Map<String, dynamic> toMap() {
    return {
      'Publisher': publisher,
      'Title': title,
      'Description': description,
      'CreatedDate': createdDate.toIso8601String(),
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
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
    };
  }

  static ActivityModel fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      publisher: map['Publisher'],
      title: map['Title'],
      description: map['Description'],
      createdDate: DateTime.parse(map['CreatedDate']),
      startDate: DateTime.parse(map['StartDate']),
      endDate: DateTime.parse(map['EndDate']),
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
    );
  }
}
