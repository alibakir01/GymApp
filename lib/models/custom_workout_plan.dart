import 'workout_plan.dart';

class CustomWorkoutPlan {
  final String id;
  final String name;
  final DateTime createdAt;
  final WorkoutPlan plan;

  CustomWorkoutPlan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.plan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'plan': plan.toJson(),
    };
  }

  factory CustomWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return CustomWorkoutPlan(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      plan: WorkoutPlan.fromJson(json['plan']),
    );
  }
}





