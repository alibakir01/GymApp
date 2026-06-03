import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_workout_plan.dart';
import '../models/workout_plan.dart';
import 'dart:convert';

class CustomWorkoutService {
  static const String _customPlansKey = 'custom_workout_plans_';

  // Save custom plan
  Future<bool> saveCustomPlan(String username, CustomWorkoutPlan customPlan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansList = await getCustomPlans(username);
      
      plansList.add(customPlan);
      
      final listJson = plansList.map((p) => p.toJson()).toList();
      await prefs.setString('$_customPlansKey$username', jsonEncode(listJson));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all custom plans
  Future<List<CustomWorkoutPlan>> getCustomPlans(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getString('$_customPlansKey$username');
      
      if (plansJson != null) {
        final List<dynamic> list = jsonDecode(plansJson);
        return list.map((json) => CustomWorkoutPlan.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Delete custom plan
  Future<bool> deleteCustomPlan(String username, String planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansList = await getCustomPlans(username);
      
      plansList.removeWhere((plan) => plan.id == planId);
      
      final listJson = plansList.map((p) => p.toJson()).toList();
      await prefs.setString('$_customPlansKey$username', jsonEncode(listJson));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Set custom plan as main plan
  Future<bool> setAsMainPlan(String username, String planId, WorkoutPlan mainPlan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Set as main plan
      await prefs.setString('workout_plan_$username', jsonEncode(mainPlan.toJson()));
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

