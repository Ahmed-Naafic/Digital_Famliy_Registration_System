/// User model for authentication
/// This class represents a user in the application with basic information

class User {
  /// Unique identifier for the user
  final String id;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// Constructor for User
  const User({required this.id, required this.name, required this.email});

  /// Create a User instance from JSON data
  /// Used when receiving user data from API responses
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  /// Convert User instance to JSON format
  /// Used when sending user data to API endpoints
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  /// Create a copy of the User with updated fields
  /// Useful for updating user information
  User copyWith({String? id, String? name, String? email}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

