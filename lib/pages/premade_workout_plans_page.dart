import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../services/workout_service.dart';

class PremadeWorkoutPlansPage extends StatelessWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const PremadeWorkoutPlansPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  static List<Map<String, dynamic>> getPlans() {
    return [
      {
        'title': 'Başlangıç Seviyesi',
        'days': 4,
        'description': 'Evde yapılabilen, ekipman gerektirmeyen program',
        'plan': _getBeginnerPlan(),
      },
      {
        'title': 'Orta Seviye',
        'days': 5,
        'description': 'Bir süre antrenman yapmış olanlar için',
        'plan': _getIntermediatePlan(),
      },
      {
        'title': 'İleri Seviye',
        'days': 6,
        'description': 'Deneyimli sporcular için yoğun program',
        'plan': _getAdvancedPlan(),
      },
      {
        'title': 'Tam Vücut',
        'days': 3,
        'description': 'Pazartesi, Perşembe, Cumartesi - Tüm kas grupları',
        'plan': _getFullBodyPlan(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plans = getPlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazır Antrenman Planları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFE5DD)],
                ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final planData = plans[index];
            return _PlanCard(
              title: planData['title'] as String,
              days: planData['days'] as int,
              description: planData['description'] as String,
              plan: planData['plan'] as WorkoutPlan,
              username: username,
              isDarkMode: isDarkMode,
              onSelect: () {
                _savePlan(context, planData['plan'] as WorkoutPlan, username);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _savePlan(BuildContext context, WorkoutPlan plan, String username) async {
    // Update plan with user's username
    final userPlan = WorkoutPlan(
      username: username,
      daysPerWeek: plan.daysPerWeek,
      dayWorkouts: plan.dayWorkouts,
    );

    final success = await WorkoutService().saveWorkoutPlan(userPlan);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Antrenman planı başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // return success to parent only once
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Simplified plans
  static WorkoutPlan _getBeginnerPlan() {
    return WorkoutPlan(
      username: 'premade',
      daysPerWeek: 4,
      dayWorkouts: [
        // Pazartesi - Göğüs & Triceps (İtme Günü)
        DayWorkout(
          dayNumber: 1,
          dayName: 'Pazartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Şınav', sets: 3, reps: 10),
                WorkoutExercise(name: 'Diz üstü şınav', sets: 3, reps: 12),
                WorkoutExercise(name: 'Dumbbell Bench Press', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Triceps',
              exercises: [
                WorkoutExercise(name: 'Triceps Dips (Sandalyede)', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank', sets: 3, reps: 30),
              ],
            ),
          ],
        ),
        // Salı - Sırt & Biceps (Çekiş Günü)
        DayWorkout(
          dayNumber: 2,
          dayName: 'Salı',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Superman', sets: 3, reps: 15),
                WorkoutExercise(name: 'Dumbbell Row (Tek Kolla Çekiş)', sets: 3, reps: 10),
                WorkoutExercise(name: 'Reverse Plank', sets: 3, reps: 30),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Biceps',
              exercises: [
                WorkoutExercise(name: 'Biceps Curl', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Karın',
              exercises: [
                WorkoutExercise(name: 'Crunch', sets: 3, reps: 15),
              ],
            ),
          ],
        ),
        // Perşembe - Bacak & Core
        DayWorkout(
          dayNumber: 4,
          dayName: 'Perşembe',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Squat', sets: 3, reps: 15),
                WorkoutExercise(name: 'Lunge (Her Bacak)', sets: 3, reps: 10),
                WorkoutExercise(name: 'Calf Raise', sets: 3, reps: 20),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Leg Raise', sets: 3, reps: 12),
                WorkoutExercise(name: 'Plank', sets: 3, reps: 30),
              ],
            ),
          ],
        ),
        // Cuma - Kardiyo & Dayanıklılık
        DayWorkout(
          dayNumber: 5,
          dayName: 'Cuma',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Kardiyo',
              exercises: [
                WorkoutExercise(name: '30 dk Orta Tempolu Yürüyüş veya Koşu', sets: 1, reps: 1),
                WorkoutExercise(name: 'Jumping Jack', sets: 3, reps: 40),
                WorkoutExercise(name: 'Mountain Climber', sets: 3, reps: 30),
                WorkoutExercise(name: 'Burpee (Yarım Burpee)', sets: 3, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Esneme',
              exercises: [
                WorkoutExercise(name: 'Esneme Hareketleri', sets: 1, reps: 1),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutPlan _getIntermediatePlan() {
    return WorkoutPlan(
      username: 'premade',
      daysPerWeek: 5,
      dayWorkouts: [
        // Salı - Göğüs & Triceps (Push Day)
        DayWorkout(
          dayNumber: 2,
          dayName: 'Salı',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Bench Press', sets: 4, reps: 10),
                WorkoutExercise(name: 'Incline Dumbbell Press', sets: 3, reps: 10),
                WorkoutExercise(name: 'Dumbbell Fly', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Triceps',
              exercises: [
                WorkoutExercise(name: 'Dips', sets: 3, reps: 10),
                WorkoutExercise(name: 'Triceps Pushdown / Dumbbell Kickback', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank', sets: 3, reps: 45),
              ],
            ),
          ],
        ),
        // Çarşamba - Sırt & Biceps (Pull Day)
        DayWorkout(
          dayNumber: 3,
          dayName: 'Çarşamba',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Pull-up (Gerekirse Destekli)', sets: 3, reps: 8),
                WorkoutExercise(name: 'Barbell Row', sets: 4, reps: 10),
                WorkoutExercise(name: 'Dumbbell One-Arm Row', sets: 3, reps: 10),
                WorkoutExercise(name: 'Face Pull / Rear Delt Fly', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Biceps',
              exercises: [
                WorkoutExercise(name: 'Barbell Curl', sets: 3, reps: 10),
                WorkoutExercise(name: 'Hammer Curl', sets: 3, reps: 12),
              ],
            ),
          ],
        ),
        // Cuma - Bacak & Core
        DayWorkout(
          dayNumber: 5,
          dayName: 'Cuma',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Squat', sets: 4, reps: 10),
                WorkoutExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
                WorkoutExercise(name: 'Lunge (Her Bacak)', sets: 3, reps: 12),
                WorkoutExercise(name: 'Leg Press', sets: 3, reps: 12),
                WorkoutExercise(name: 'Calf Raise', sets: 4, reps: 20),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Hanging Leg Raise', sets: 3, reps: 12),
                WorkoutExercise(name: 'Russian Twist', sets: 3, reps: 20),
              ],
            ),
          ],
        ),
        // Cumartesi - Omuz & Karın
        DayWorkout(
          dayNumber: 6,
          dayName: 'Cumartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Omuz',
              exercises: [
                WorkoutExercise(name: 'Overhead Press', sets: 4, reps: 10),
                WorkoutExercise(name: 'Lateral Raise', sets: 3, reps: 15),
                WorkoutExercise(name: 'Front Raise', sets: 3, reps: 12),
                WorkoutExercise(name: 'Rear Delt Fly', sets: 3, reps: 15),
                WorkoutExercise(name: 'Shrug', sets: 3, reps: 15),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Karın',
              exercises: [
                WorkoutExercise(name: 'Cable Crunch', sets: 3, reps: 20),
                WorkoutExercise(name: 'Side Plank (Her Taraf)', sets: 3, reps: 30),
              ],
            ),
          ],
        ),
        // Pazar - Kardiyo + Full Body (Metabolic Day)
        DayWorkout(
          dayNumber: 0,
          dayName: 'Pazar',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Kardiyo',
              exercises: [
                WorkoutExercise(name: '10 dk Koşu (Orta-Hızlı Tempo)', sets: 1, reps: 1),
                WorkoutExercise(name: 'Jump Squat', sets: 3, reps: 15),
                WorkoutExercise(name: 'Burpee', sets: 3, reps: 12),
                WorkoutExercise(name: 'Mountain Climber', sets: 3, reps: 40),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Tam Vücut',
              exercises: [
                WorkoutExercise(name: 'Push-up to Plank', sets: 3, reps: 12),
                WorkoutExercise(name: 'Plank to Shoulder Tap', sets: 3, reps: 20),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Soğuma',
              exercises: [
                WorkoutExercise(name: '5-10 dk Soğuma Yürüyüşü', sets: 1, reps: 1),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutPlan _getAdvancedPlan() {
    return WorkoutPlan(
      username: 'premade',
      daysPerWeek: 6,
      dayWorkouts: [
        // Pazar - Göğüs & Triceps (Push A)
        DayWorkout(
          dayNumber: 0,
          dayName: 'Pazar',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Flat Bench Press', sets: 5, reps: 8),
                WorkoutExercise(name: 'Incline Dumbbell Press', sets: 4, reps: 10),
                WorkoutExercise(name: 'Cable Crossover / Pec Deck', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Triceps',
              exercises: [
                WorkoutExercise(name: 'Weighted Dips', sets: 3, reps: 10),
                WorkoutExercise(name: 'Close Grip Bench Press', sets: 3, reps: 10),
                WorkoutExercise(name: 'Rope Pushdown (Drop Set)', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank', sets: 3, reps: 60),
              ],
            ),
          ],
        ),
        // Pazartesi - Sırt & Biceps (Pull A)
        DayWorkout(
          dayNumber: 1,
          dayName: 'Pazartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Deadlift', sets: 4, reps: 6),
                WorkoutExercise(name: 'Pull-up (Weighted)', sets: 4, reps: 8),
                WorkoutExercise(name: 'Barbell Row', sets: 4, reps: 10),
                WorkoutExercise(name: 'Lat Pulldown (Narrow Grip)', sets: 3, reps: 12),
                WorkoutExercise(name: 'Seated Cable Row', sets: 3, reps: 12),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Biceps',
              exercises: [
                WorkoutExercise(name: 'Barbell Curl', sets: 3, reps: 10),
                WorkoutExercise(name: 'Incline Dumbbell Curl', sets: 3, reps: 12),
                WorkoutExercise(name: 'Hammer Curl', sets: 3, reps: 12),
              ],
            ),
          ],
        ),
        // Salı - Bacak (Leg Day A)
        DayWorkout(
          dayNumber: 2,
          dayName: 'Salı',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Barbell Squat', sets: 5, reps: 8),
                WorkoutExercise(name: 'Romanian Deadlift', sets: 4, reps: 10),
                WorkoutExercise(name: 'Leg Press', sets: 4, reps: 12),
                WorkoutExercise(name: 'Walking Lunge', sets: 3, reps: 12),
                WorkoutExercise(name: 'Leg Extension (Drop Set)', sets: 3, reps: 15),
                WorkoutExercise(name: 'Seated Calf Raise', sets: 4, reps: 20),
                WorkoutExercise(name: 'Standing Calf Raise', sets: 3, reps: 20),
              ],
            ),
          ],
        ),
        // Perşembe - Omuz & Core
        DayWorkout(
          dayNumber: 4,
          dayName: 'Perşembe',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Omuz',
              exercises: [
                WorkoutExercise(name: 'Overhead Press', sets: 4, reps: 8),
                WorkoutExercise(name: 'Dumbbell Lateral Raise', sets: 4, reps: 15),
                WorkoutExercise(name: 'Front Raise', sets: 3, reps: 12),
                WorkoutExercise(name: 'Rear Delt Fly', sets: 4, reps: 15),
                WorkoutExercise(name: 'Upright Row', sets: 3, reps: 10),
                WorkoutExercise(name: 'Shrug', sets: 4, reps: 15),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Hanging Leg Raise', sets: 4, reps: 15),
                WorkoutExercise(name: 'Cable Crunch', sets: 3, reps: 20),
              ],
            ),
          ],
        ),
        // Cuma - Göğüs & Sırt (Push-Pull Combo)
        DayWorkout(
          dayNumber: 5,
          dayName: 'Cuma',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Incline Bench Press', sets: 4, reps: 10),
                WorkoutExercise(name: 'Dumbbell Fly', sets: 3, reps: 12),
                WorkoutExercise(name: 'Push-up (AMRAP)', sets: 3, reps: 20),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Weighted Pull-up', sets: 4, reps: 8),
                WorkoutExercise(name: 'T-Bar Row', sets: 3, reps: 10),
                WorkoutExercise(name: 'Seated Row', sets: 3, reps: 12),
                WorkoutExercise(name: 'Hyperextension', sets: 3, reps: 15),
              ],
            ),
          ],
        ),
        // Cumartesi - Bacak & Kardiyo (Leg Day B + HIIT)
        DayWorkout(
          dayNumber: 6,
          dayName: 'Cumartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Front Squat', sets: 4, reps: 8),
                WorkoutExercise(name: 'Bulgarian Split Squat', sets: 3, reps: 10),
                WorkoutExercise(name: 'Leg Curl', sets: 4, reps: 12),
                WorkoutExercise(name: 'Calf Raise', sets: 4, reps: 20),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Kardiyo',
              exercises: [
                WorkoutExercise(name: '15-20 dk HIIT Kardiyo', sets: 1, reps: 1),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutPlan _getFullBodyPlan() {
    return WorkoutPlan(
      username: 'premade',
      daysPerWeek: 3,
      dayWorkouts: [
        // Pazartesi - Tam Vücut
        DayWorkout(
          dayNumber: 1,
          dayName: 'Pazartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Squat', sets: 4, reps: 10),
                WorkoutExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Bench Press', sets: 4, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Barbell Row', sets: 4, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Omuz',
              exercises: [
                WorkoutExercise(name: 'Overhead Press', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt Genişliği',
              exercises: [
                WorkoutExercise(name: 'Pull-up / Lat Pulldown', sets: 3, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank (45 sn) + Leg Raise (15 tekrar)', sets: 3, reps: 1),
              ],
            ),
          ],
        ),
        // Perşembe - Tam Vücut
        DayWorkout(
          dayNumber: 4,
          dayName: 'Perşembe',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Squat', sets: 4, reps: 10),
                WorkoutExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Bench Press', sets: 4, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Barbell Row', sets: 4, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Omuz',
              exercises: [
                WorkoutExercise(name: 'Overhead Press', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt Genişliği',
              exercises: [
                WorkoutExercise(name: 'Pull-up / Lat Pulldown', sets: 3, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank (45 sn) + Leg Raise (15 tekrar)', sets: 3, reps: 1),
              ],
            ),
          ],
        ),
        // Cumartesi - Tam Vücut
        DayWorkout(
          dayNumber: 6,
          dayName: 'Cumartesi',
          muscleGroups: [
            WorkoutMuscleGroup(
              name: 'Bacak',
              exercises: [
                WorkoutExercise(name: 'Squat', sets: 4, reps: 10),
                WorkoutExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Göğüs',
              exercises: [
                WorkoutExercise(name: 'Bench Press', sets: 4, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt',
              exercises: [
                WorkoutExercise(name: 'Barbell Row', sets: 4, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Omuz',
              exercises: [
                WorkoutExercise(name: 'Overhead Press', sets: 3, reps: 10),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Sırt Genişliği',
              exercises: [
                WorkoutExercise(name: 'Pull-up / Lat Pulldown', sets: 3, reps: 8),
              ],
            ),
            WorkoutMuscleGroup(
              name: 'Core',
              exercises: [
                WorkoutExercise(name: 'Plank (45 sn) + Leg Raise (15 tekrar)', sets: 3, reps: 1),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final int days;
  final String description;
  final WorkoutPlan plan;
  final String username;
  final bool isDarkMode;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.title,
    required this.days,
    required this.description,
    required this.plan,
    required this.username,
    required this.isDarkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFFFF6B35),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          '$days Gün/Hafta',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFFF6B35),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

