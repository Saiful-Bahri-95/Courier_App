import 'dart:convert';

class User {
  //define field
  final String id;
  final String fullname;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String password;
  final String token;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.password,
    required this.token,
  });

  //Serialization:Convert User object to Map
  //Map: A map is a collection of key-value pairs
  //why: Converting to a map makes it easier to store and transmit data

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'fullname': fullname,
      'email': email,
      'state': state,
      'city': city,
      'locality': locality,
      'password': password,
      'token': token,
    };
  }

  //Serialization:Convert Map to User object (a JSON String )
  String toJson() => json.encode(toMap());

  //Deserialization:Convert Map to User object
  //why: Converting from a map allows us to reconstruct the User object from stored or transmitted data
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      //perhatikan disini _id harus sesuai dengan nama field di database
      id: map['_id'] as String? ?? '',
      fullname: map['fullname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      state: map['state'] as String? ?? '',
      city: map['city'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      password: map['password'] as String? ?? '',
      token: map['token'] as String? ?? '',
    );
  }

  //FromJSon: This factory constructor takes JSON string, and decode into Map

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
