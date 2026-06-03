import 'package:shared_preferences/shared_preferences.dart';

class WorkoutHistoryService {
  static final WorkoutHistoryService _instance = WorkoutHistoryService._internal();
  factory WorkoutHistoryService() => _instance;
  WorkoutHistoryService._internal();

  // Save today's workout time (adds to existing total)
  Future<bool> saveTodayWorkoutTime(String username, int newMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD format
      
      // Get existing minutes and add to them
      final existingMinutes = prefs.getInt('${username}_workout_$today') ?? 0;
      await prefs.setInt('${username}_workout_$today', existingMinutes + newMinutes);
      await prefs.setString('${username}_last_workout_date', today);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Save today's calories burned
  Future<bool> saveTodayCalories(String username, double calories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0];
      
      // Get existing calories and add to them
      final existingCalories = prefs.getDouble('${username}_calories_$today') ?? 0.0;
      await prefs.setDouble('${username}_calories_$today', existingCalories + calories);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get today's calories
  Future<double> getTodayCalories(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0];
      
      return prefs.getDouble('${username}_calories_$today') ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Get today's workout time
  Future<int> getTodayWorkoutTime(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0];
      
      return prefs.getInt('${username}_workout_$today') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Check if we need to reset (new day)
  Future<void> checkAndResetIfNewDay(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('${username}_last_workout_date');
    final today = DateTime.now().toString().split(' ')[0];
    
    if (lastDate != today && lastDate != null) {
      // New day started, reset today's workout time
      final workoutMinutes = prefs.getInt('${username}_workout_$today') ?? 0;
      if (workoutMinutes == 0) {
        // Only reset if not already set for today
        await prefs.setInt('${username}_workout_$today', 0);
      }
    }
  }

  // Get all workout history
  Future<Map<String, int>> getWorkoutHistory(String username, int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> history = {};
      
      for (int i = 0; i < days; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateString = date.toString().split(' ')[0];
        final minutes = prefs.getInt('${username}_workout_$dateString') ?? 0;
        history[dateString] = minutes;
      }
      
      return history;
    } catch (e) {
      return {};
    }
  }
}


