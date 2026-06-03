
class WorkoutExercise {
  final String name;
  final int sets;
  final int reps;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
    );
  }
}

class WorkoutMuscleGroup {
  final String name;
  final List<WorkoutExercise> exercises;

  WorkoutMuscleGroup({
    required this.name,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory WorkoutMuscleGroup.fromJson(Map<String, dynamic> json) {
    return WorkoutMuscleGroup(
      name: json['name'] ?? '',
      exercises: (json['exercises'] as List?)
          ?.map((e) => WorkoutExercise.fromJson(e))
          .toList() ?? [],
    );
  }
}

class DayWorkout {
  final int dayNumber;
  final String dayName;
  final List<WorkoutMuscleGroup> muscleGroups;

  DayWorkout({
    required this.dayNumber,
    required this.dayName,
    required this.muscleGroups,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'dayName': dayName,
      'muscleGroups': muscleGroups.map((mg) => mg.toJson()).toList(),
    };
  }

  factory DayWorkout.fromJson(Map<String, dynamic> json) {
    return DayWorkout(
      dayNumber: json['dayNumber'] ?? 0,
      dayName: json['dayName'] ?? '',
      muscleGroups: (json['muscleGroups'] as List?)
          ?.map((mg) => WorkoutMuscleGroup.fromJson(mg))
          .toList() ?? [],
    );
  }
}

class WorkoutPlan {
  final String username;
  final int daysPerWeek;
  final List<DayWorkout> dayWorkouts;

  WorkoutPlan({
    required this.username,
    required this.daysPerWeek,
    required this.dayWorkouts,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'daysPerWeek': daysPerWeek,
      'dayWorkouts': dayWorkouts.map((dw) => dw.toJson()).toList(),
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      username: json['username'] ?? '',
      daysPerWeek: json['daysPerWeek'] ?? 0,
      dayWorkouts: (json['dayWorkouts'] as List?)
          ?.map((dw) => DayWorkout.fromJson(dw))
          .toList() ?? [],
    );
  }
}

