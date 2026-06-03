import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../models/custom_workout_plan.dart';
import '../services/custom_workout_service.dart';

class CreateCustomPlanPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CreateCustomPlanPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CreateCustomPlanPage> createState() => _CreateCustomPlanPageState();
}

class _CreateCustomPlanPageState extends State<CreateCustomPlanPage> {
  final List<String> _daysOfWeek = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  int _selectedDaysCount = 3;
  final List<bool> _selectedDays = [true, true, true, false, false, false, false];
  final List<DayWorkout> _dayWorkouts = [];
  bool _isSaving = false;
  final TextEditingController _planNameController = TextEditingController();
  final CustomWorkoutService _customService = CustomWorkoutService();

  @override
  void initState() {
    super.initState();
    _initializeDays();
  }

  void _initializeDays() {
    _dayWorkouts.clear();
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        _dayWorkouts.add(DayWorkout(
          dayNumber: i + 1,
          dayName: _daysOfWeek[i],
          muscleGroups: [],
        ));
      }
    }
  }

  void _updateSelectedDays() {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        count++;
      }
    }
    
    // Update day workouts based on selection
    _dayWorkouts.clear();
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        _dayWorkouts.add(DayWorkout(
          dayNumber: i + 1,
          dayName: _daysOfWeek[i],
          muscleGroups: [],
        ));
      }
    }
    
    setState(() {
      _selectedDaysCount = count;
    });
  }

  Future<void> _savePlan() async {
    if (_dayWorkouts.every((dw) => dw.muscleGroups.isEmpty)) {
      _showError('En az bir günde antrenman planı oluşturmalısınız');
      return;
    }

    // Show dialog to get plan name
    final planName = await _showPlanNameDialog();
    if (planName == null || planName.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final plan = WorkoutPlan(
      username: widget.username,
      daysPerWeek: _selectedDaysCount,
      dayWorkouts: _dayWorkouts,
    );

    // Create custom plan item
    final customPlan = CustomWorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: planName,
      createdAt: DateTime.now(),
      plan: plan,
    );

    final success = await _customService.saveCustomPlan(widget.username, customPlan);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      _showSuccess('Program başarıyla kaydedildi!');
      await Future.delayed(const Duration(milliseconds: 600));
      Navigator.pop(context, true);
    } else {
      _showError('Program kaydedilirken bir hata oluştu');
    }
  }

  Future<String?> _showPlanNameDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Program Adı'),
        content: TextField(
          controller: _planNameController,
          decoration: const InputDecoration(
            hintText: 'Örn: Kış Programı, Kas Yapma Programı',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _planNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _planNameController.text);
              _planNameController.clear();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendi Programını Oluştur'),
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
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Haftanın Kaç Günü Antrenman Yapacaksınız?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Days of week selector
                      ...List.generate(7, (index) {
                        return CheckboxListTile(
                          title: Text(_daysOfWeek[index]),
                          value: _selectedDays[index],
                          onChanged: (value) {
                            setState(() {
                              _selectedDays[index] = value ?? false;
                              _updateSelectedDays();
                            });
                          },
                          activeColor: const Color(0xFFFF6B35),
                        );
                      }),

                      const SizedBox(height: 32),

                      // Day workouts
                      Text(
                        'Antrenman Detayları',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._dayWorkouts.map((dayWorkout) {
                        return _DayWorkoutCard(
                          dayWorkout: dayWorkout,
                          isDarkMode: widget.isDarkMode,
                          onTap: () {
                            _openDayDetails(dayWorkout);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // Save button
              Container(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePlan,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Planı Kaydet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDayDetails(DayWorkout dayWorkout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DayDetailsPage(
          dayWorkout: dayWorkout,
          isDarkMode: widget.isDarkMode,
          onSave: (updatedDay) {
            setState(() {
              final index = _dayWorkouts.indexOf(dayWorkout);
              if (index != -1) {
                _dayWorkouts[index] = updatedDay;
              }
            });
          },
        ),
      ),
    );
  }
}

class _DayWorkoutCard extends StatelessWidget {
  final DayWorkout dayWorkout;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _DayWorkoutCard({
    required this.dayWorkout,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muscleCount = dayWorkout.muscleGroups.length;
    final exerciseCount = dayWorkout.muscleGroups.fold<int>(
      0,
      (sum, mg) => sum + mg.exercises.length,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: muscleCount > 0 
                ? const Color(0xFFFF6B35) 
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayWorkout.dayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    muscleCount > 0
                        ? '$muscleCount kas grubu, $exerciseCount egzersiz'
                        : 'Henüz antrenman eklenmedi',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFFFF6B35),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Day Details Page
class _DayDetailsPage extends StatefulWidget {
  final DayWorkout dayWorkout;
  final bool isDarkMode;
  final Function(DayWorkout) onSave;

  const _DayDetailsPage({
    required this.dayWorkout,
    required this.isDarkMode,
    required this.onSave,
  });

  @override
  State<_DayDetailsPage> createState() => _DayDetailsPageState();
}

class _DayDetailsPageState extends State<_DayDetailsPage> {
  late DayWorkout _dayWorkout;

  @override
  void initState() {
    super.initState();
    _dayWorkout = widget.dayWorkout;
  }

  void _addMuscleGroup() {
    showDialog(
      context: context,
      builder: (context) => _AddMuscleGroupDialog(
        isDarkMode: widget.isDarkMode,
        onSave: (name) {
          setState(() {
            _dayWorkout.muscleGroups.add(
              WorkoutMuscleGroup(name: name, exercises: []),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addExercise(int muscleIndex) {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        isDarkMode: widget.isDarkMode,
        onSave: (exercise) {
          setState(() {
            _dayWorkout.muscleGroups[muscleIndex].exercises.add(exercise);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dayWorkout.dayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onSave(_dayWorkout);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kas Grupları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_dayWorkout.muscleGroups.isEmpty)
                      Center(
                        child: Text(
                          'Henüz kas grubu eklenmedi',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[700],
                          ),
                        ),
                      ),

                    ..._dayWorkout.muscleGroups.asMap().entries.map((entry) {
                      int index = entry.key;
                      WorkoutMuscleGroup muscle = entry.value;
                      
                      return _MuscleGroupCard(
                        muscleGroup: muscle,
                        isDarkMode: widget.isDarkMode,
                        onAddExercise: () => _addExercise(index),
                        onDelete: () {
                          setState(() {
                            _dayWorkout.muscleGroups.removeAt(index);
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _addMuscleGroup,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Kas Grubu Ekle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleGroupCard extends StatelessWidget {
  final WorkoutMuscleGroup muscleGroup;
  final bool isDarkMode;
  final VoidCallback onAddExercise;
  final VoidCallback onDelete;

  const _MuscleGroupCard({
    required this.muscleGroup,
    required this.isDarkMode,
    required this.onAddExercise,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B35),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: const Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  muscleGroup.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (muscleGroup.exercises.isEmpty)
            Text(
              'Henüz egzersiz eklenmedi',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
          
          ...muscleGroup.exercises.map((exercise) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    '${exercise.sets} x ${exercise.reps}',
                    style: TextStyle(
                      color: const Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddExercise,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Egzersiz Ekle'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMuscleGroupDialog extends StatefulWidget {
  final bool isDarkMode;
  final Function(String) onSave;

  const _AddMuscleGroupDialog({
    required this.isDarkMode,
    required this.onSave,
  });

  @override
  State<_AddMuscleGroupDialog> createState() => _AddMuscleGroupDialogState();
}

class _AddMuscleGroupDialogState extends State<_AddMuscleGroupDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kas Grubu Ekle'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Örn: Göğüs, Sırt, Bacak',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text);
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final bool isDarkMode;
  final Function(WorkoutExercise) onSave;

  const _AddExerciseDialog({
    required this.isDarkMode,
    required this.onSave,
  });

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Egzersiz Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Egzersiz adı',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Set',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Tekrar',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(WorkoutExercise(
                name: _nameController.text,
                sets: int.tryParse(_setsController.text) ?? 3,
                reps: int.tryParse(_repsController.text) ?? 10,
              ));
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

