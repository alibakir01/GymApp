import 'package:flutter/material.dart';
import '../services/custom_workout_service.dart';
import '../services/workout_service.dart';
import '../models/custom_workout_plan.dart';
import '../models/workout_plan.dart';
import 'view_workout_plan_page.dart';

class MyProgramsPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MyProgramsPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MyProgramsPage> createState() => _MyProgramsPageState();
}

class _MyProgramsPageState extends State<MyProgramsPage> {
  final CustomWorkoutService _customService = CustomWorkoutService();
  final WorkoutService _workoutService = WorkoutService();
  List<CustomWorkoutPlan> _customPlans = [];
  WorkoutPlan? _mainPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final customPlans = await _customService.getCustomPlans(widget.username);
    final mainPlan = await _workoutService.getWorkoutPlan(widget.username);
    
    setState(() {
      _customPlans = customPlans;
      _mainPlan = mainPlan;
      _isLoading = false;
    });
  }

  Future<void> _deletePlan(String planId) async {
    final success = await _customService.deleteCustomPlan(widget.username, planId);
    
    if (success && mounted) {
      _loadPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program silindi')),
      );
    }
  }

  Future<void> _setAsMainPlan(String planId) async {
    final planItem = _customPlans.firstWhere((p) => p.id == planId);
    
    final mainPlan = WorkoutPlan(
      username: widget.username,
      daysPerWeek: planItem.plan.daysPerWeek,
      dayWorkouts: planItem.plan.dayWorkouts,
    );
    
    final success = await _workoutService.saveWorkoutPlan(mainPlan);
    
    if (success && mounted) {
      setState(() {
        _mainPlan = mainPlan;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program ana program olarak ayarlandı')),
      );
    }
  }

  void _showDeleteDialog(String planId, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil'),
        content: Text('$planName programını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlan(planId);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programlarım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Plan
                    if (_mainPlan != null) ...[
                      _buildSectionTitle('Aktif Program'),
                      _buildPlanCard(_mainPlan!.dayWorkouts, 'Aktif Program', isMain: true),
                      const SizedBox(height: 32),
                    ],
                    
                    // Custom Plans
                    _buildSectionTitle('Kayıtlı Programlarım'),
                    
                    if (_customPlans.isEmpty)
                      Center(
                        child: Text(
                          'Henüz program kaydetmediniz',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      ..._customPlans.map((plan) => _buildCustomPlanCard(plan)).toList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPlanCard(List<DayWorkout> dayWorkouts, String name, {bool isMain = false}) {
    return Card(
      color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      child: InkWell(
        onTap: () {
          final plan = WorkoutPlan(
            username: widget.username,
            daysPerWeek: dayWorkouts.length,
            dayWorkouts: dayWorkouts,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewWorkoutPlanPage(
                username: widget.username,
                plan: plan,
                toggleTheme: widget.toggleTheme,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${dayWorkouts.length} gün',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPlanCard(CustomWorkoutPlan plan) {
    return Card(
      color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              plan.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              '${plan.createdAt.day}/${plan.createdAt.month}/${plan.createdAt.year} - ${plan.plan.dayWorkouts.length} gün',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWorkoutPlanPage(
                          username: widget.username,
                          plan: plan.plan,
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Görüntüle',
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: () => _setAsMainPlan(plan.id),
                  tooltip: 'Aktif yap',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(plan.id, plan.name),
                  tooltip: 'Sil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




