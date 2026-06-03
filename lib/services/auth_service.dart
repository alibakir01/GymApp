import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _usersKey = 'registered_users';
  static const String _loggedInKey = 'isLoggedIn';
  static const String _usernameKey = 'username';

  // Register a new user
  Future<bool> registerUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      List<User> users = [];

      if (usersJson != null) {
        users = User.fromJsonList(usersJson);
      }

      // Check if username already exists
      bool usernameExists = users.any((u) => u.username == user.username);
      if (usernameExists) {
        return false; // Username already exists
      }

      users.add(user);
      await prefs.setString(_usersKey, User.toJsonList(users));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Login user
  Future<bool> loginUser(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) {
        return false;
      }

      List<User> users = User.fromJsonList(usersJson);
      User? user = users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => User(email: '', username: '', password: ''),
      );

      if (user.username.isEmpty) {
        return false;
      }

      // Save login status
      await prefs.setBool(_loggedInKey, true);
      await prefs.setString(_usernameKey, username);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_usernameKey);
  }

  // Check if username exists
  Future<bool> isUsernameTaken(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) {
        return false;
      }

      List<User> users = User.fromJsonList(usersJson);
      return users.any((u) => u.username == username);
    } catch (e) {
      return false;
    }
  }
}


