class OrganizationModel {
  final String? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final List<String> members;
  final List<String> admins;
  final List<String> activities;
  final String email;

  OrganizationModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.members,
    required this.admins,
    required this.activities,
    required this.email,
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
    };
  }
}
