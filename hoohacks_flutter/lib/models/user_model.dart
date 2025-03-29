// Name: String
// Email: String
// Username: String
// Bio: String
// Year: String
// Organization: <String[OrgId]>[]
// Participating: <String[ActId]>[]
// Interest: <String>[]

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String year;
  final List<String> organization;
  final List<String> participating;
  final List<String> interest;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    required this.year,
    required this.organization,
    required this.participating,
    required this.interest,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Name': name,
      'Email': email,
      'Username': username,
      'Bio': bio,
      'Year': year,
      'Organization': organization,
      'Participating': participating,
      'Interest': interest,
    };
  }
}
