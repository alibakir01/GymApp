import 'dart:convert';

class User {
  final String email;
  final String username;
  final String password;

  User({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  static List<User> fromJsonList(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((json) => User.fromJson(json)).toList();
  }

  static String toJsonList(List<User> users) {
    final List<Map<String, dynamic>> jsonList = users.map((user) => user.toJson()).toList();
    return jsonEncode(jsonList);
  }
}


