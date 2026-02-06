import 'dart:convert';

class User {
  final String id;
  final String fullname;
  final String email;
  final String token;
  final String? avatar;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.token,
    this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'fullname': fullname,
      'email': email,
      'token': token,
      'avatar': avatar,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      fullname: map['fullname'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      avatar: map['avatar'], // boleh null
    );
  }

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));
}
