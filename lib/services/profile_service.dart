import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Calculate BMI
  static double calculateBMI(double height, double weight) {
    if (height == 0) return 0;
    // BMI = weight (kg) / height (m) ^ 2
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Zayıf';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Fazla Kilolu';
    } else {
      return 'Obez';
    }
  }

  // Save user profile
  Future<bool> saveProfile(String username, double height, double weight, int age, 
      {String? goal, String? gender, double? targetWeight, double? bodyFat, double? targetBodyFat}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${username}_height', height.toString());
      await prefs.setString('${username}_weight', weight.toString());
      await prefs.setInt('${username}_age', age);
      if (goal != null) await prefs.setString('${username}_goal', goal);
      if (gender != null) await prefs.setString('${username}_gender', gender);
      if (targetWeight != null) await prefs.setString('${username}_targetWeight', targetWeight.toString());
      if (bodyFat != null) await prefs.setString('${username}_bodyFat', bodyFat.toString());
      if (targetBodyFat != null) await prefs.setString('${username}_targetBodyFat', targetBodyFat.toString());
      await prefs.setBool('${username}_has_profile', true);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final heightStr = prefs.getString('${username}_height');
    final weightStr = prefs.getString('${username}_weight');
    final age = prefs.getInt('${username}_age');
    final hasProfile = prefs.getBool('${username}_has_profile') ?? false;

    if (hasProfile && heightStr != null && weightStr != null) {
      return {
        'height': double.parse(heightStr),
        'weight': double.parse(weightStr),
        'age': age ?? 0,
        'goal': prefs.getString('${username}_goal') ?? '',
        'gender': prefs.getString('${username}_gender'),
        'targetWeight': prefs.getString('${username}_targetWeight'),
        'bodyFat': prefs.getString('${username}_bodyFat'),
        'targetBodyFat': prefs.getString('${username}_targetBodyFat'),
        'hasProfile': true,
      };
    }

    return {
      'hasProfile': false,
    };
  }

  // Check if user has profile
  Future<bool> hasProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${username}_has_profile') ?? false;
  }

  // Update profile
  Future<bool> updateProfile(String username, double height, double weight, int age,
      {String? goal, String? gender, double? targetWeight, double? bodyFat, double? targetBodyFat}) async {
    return await saveProfile(username, height, weight, age, 
      goal: goal, 
      gender: gender,
      targetWeight: targetWeight, 
      bodyFat: bodyFat, 
      targetBodyFat: targetBodyFat);
  }
}

