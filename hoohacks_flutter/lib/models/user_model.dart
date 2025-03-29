class UserModel {
  final String? id;
  final String name;
  final String email;
  final String username;
  final String bio;
  final List<String> organization;
  final List<String> participating;
  final List<String> interest;
  final List<String> upvotedActivities;
  final List<String> downvotedActivities;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    required this.organization,
    required this.participating,
    required this.interest,
    required this.upvotedActivities,
    required this.downvotedActivities,
  });

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Email': email,
      'Username': username,
      'Bio': bio,
      'Organization': organization,
      'Participating': participating,
      'Interest': interest,
      'UpvotedActivities': upvotedActivities,
      'DownvotedActivities': downvotedActivities,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['Name'],
      email: map['Email'],
      username: map['Username'],
      bio: map['Bio'],
      organization: List<String>.from(map['Organization']),
      participating: List<String>.from(map['Participating']),
      interest: List<String>.from(map['Interest']),
      upvotedActivities: List<String>.from(map['UpvotedActivities']),
      downvotedActivities: List<String>.from(map['DownvotedActivities']),
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, username: $username, bio: $bio, organization: $organization, participating: $participating, interest: $interest, upvotedActivities: $upvotedActivities, downvotedActivities: $downvotedActivities}';
  }
}
