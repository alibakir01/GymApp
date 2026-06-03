import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import 'dart:convert';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  // Save workout plan
  Future<bool> saveWorkoutPlan(WorkoutPlan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = jsonEncode(plan.toJson());
      await prefs.setString('workout_plan_${plan.username}', planJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get workout plan
  Future<WorkoutPlan?> getWorkoutPlan(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString('workout_plan_$username');
      
      if (planJson == null) {
        return null;
      }

      final planData = jsonDecode(planJson) as Map<String, dynamic>;
      return WorkoutPlan.fromJson(planData);
    } catch (e) {
      return null;
    }
  }

  // Check if user has workout plan
  Future<bool> hasWorkoutPlan(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString('workout_plan_$username');
      return planJson != null;
    } catch (e) {
      return false;
    }
  }

  // Delete workout plan
  Future<bool> deleteWorkoutPlan(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('workout_plan_$username');
      return true;
    } catch (e) {
      return false;
    }
  }
}


