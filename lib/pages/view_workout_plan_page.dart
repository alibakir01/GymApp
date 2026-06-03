import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../services/workout_service.dart';

class ViewWorkoutPlanPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final WorkoutPlan? plan;

  const ViewWorkoutPlanPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
    this.plan,
  });

  @override
  State<ViewWorkoutPlanPage> createState() => _ViewWorkoutPlanPageState();
}

class _ViewWorkoutPlanPageState extends State<ViewWorkoutPlanPage> {
  WorkoutPlan? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _plan = widget.plan;
      _isLoading = false;
    } else {
      _loadPlan();
    }
  }

  Future<void> _loadPlan() async {
    final plan = await WorkoutService().getWorkoutPlan(widget.username);
    setState(() {
      _plan = plan;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenman Planım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plan == null
              ? Center(
                  child: Text(
                    'Henüz plan oluşturulmamış',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: widget.isDarkMode
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Toplam ${_plan!.daysPerWeek} Gün Antrenman',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _plan!.dayWorkouts.length.toString() + ' gün',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Day Workouts
                        ..._plan!.dayWorkouts.map((dayWorkout) {
                          return _DayWorkoutViewCard(
                            dayWorkout: dayWorkout,
                            isDarkMode: widget.isDarkMode,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _DayWorkoutViewCard extends StatelessWidget {
  final DayWorkout dayWorkout;
  final bool isDarkMode;

  const _DayWorkoutViewCard({
    required this.dayWorkout,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Day Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  dayWorkout.dayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Muscle Groups
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (dayWorkout.muscleGroups.isEmpty)
                  Center(
                    child: Text(
                      'Bu gün için plan eklenmemiş',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
                      ),
                    ),
                  ),
                
                ...dayWorkout.muscleGroups.map((muscleGroup) {
                  return _MuscleGroupView(
                    muscleGroup: muscleGroup,
                    isDarkMode: isDarkMode,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleGroupView extends StatelessWidget {
  final WorkoutMuscleGroup muscleGroup;
  final bool isDarkMode;

  const _MuscleGroupView({
    required this.muscleGroup,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, 
                   color: const Color(0xFFFF6B35), size: 20),
              const SizedBox(width: 8),
              Text(
                muscleGroup.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          ...muscleGroup.exercises.map((exercise) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const SizedBox(width: 28),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${exercise.sets} x ${exercise.reps}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

