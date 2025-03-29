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
  final String upvotes;
  final String downvotes;
  final bool organizationOnly;
  final List<String> years;

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
    required this.years,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
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
      'Years': years,
    };
  }
}
