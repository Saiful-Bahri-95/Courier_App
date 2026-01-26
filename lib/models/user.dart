import 'dart:convert';

class User {
  final String id;
  final String fullname;
  final String email;
  final String token;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.token,
  });

  /// Convert User object to Map (for storage / usage)
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'fullname': fullname,
      'email': email,
      'token': token,
    };
  }

  /// Convert User object to JSON string
  String toJson() => jsonEncode(toMap());

  /// Create User object from Map (API response)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      fullname: map['fullname'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Create User object from JSON string
  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));
}
