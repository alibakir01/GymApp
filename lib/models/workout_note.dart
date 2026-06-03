class WorkoutNote {
  final String id;
  final DateTime date;
  final String exerciseName;
  final double weight;
  final int reps;
  final String? comment;

  WorkoutNote({
    required this.id,
    required this.date,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    this.comment,
  });

  WorkoutNote copyWith({
    String? id,
    DateTime? date,
    String? exerciseName,
    double? weight,
    int? reps,
    String? comment,
  }) {
    return WorkoutNote(
      id: id ?? this.id,
      date: date ?? this.date,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'comment': comment,
    };
  }

  factory WorkoutNote.fromJson(Map<String, dynamic> json) {
    return WorkoutNote(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      comment: json['comment'] as String?,
    );
  }
}





