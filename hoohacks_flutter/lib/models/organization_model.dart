class OrganizationModel {
  final String? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final List<String> members;
  final List<String> admins;
  final List<String> activities;
  final String email;
  final String? location;
  final String? profilePicture;

  OrganizationModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.members,
    required this.admins,
    required this.activities,
    required this.email,
    required this.location,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'CreatedDate': createdDate.toIso8601String(),
      'Members': members,
      'Admins': admins,
      'Activities': activities,
      'Email': email,
      'Location': location,
      'ProfilePicture': profilePicture,
    };
  }

  static OrganizationModel fromMap(Map<String, dynamic> map, String id) {
    return OrganizationModel(
      id: id,
      name: map['Name'],
      description: map['Description'],
      createdDate: DateTime.parse(map['CreatedDate']),
      members: List<String>.from(map['Members']),
      admins: List<String>.from(map['Admins']),
      activities: List<String>.from(map['Activities']),
      email: map['Email'],
      location: map['Location'],
      profilePicture: map['ProfilePicture'],
    );
  }

  @override
  String toString() {
    return 'OrganizationModel{id: $id, name: $name, description: $description, createdDate: $createdDate, members: $members, admins: $admins, activities: $activities, email: $email, location: $location, profilePicture: $profilePicture}';
  }
}
