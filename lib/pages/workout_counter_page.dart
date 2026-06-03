import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import '../services/workout_history_service.dart';
import '../services/profile_service.dart';
import '../services/workout_timer_service.dart';

class WorkoutCounterPage extends StatefulWidget {
  final DayWorkout? dayWorkout;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final String? initialActivityType; // 'walking' | 'running' | 'weightlifting'
  final String? initialRunningPace; // 'slow' | 'medium' | 'fast'

  const WorkoutCounterPage({
    super.key,
    this.dayWorkout,
    required this.toggleTheme,
    required this.isDarkMode,
    this.initialActivityType,
    this.initialRunningPace,
  });

  @override
  State<WorkoutCounterPage> createState() => _WorkoutCounterPageState();
}

class _WorkoutCounterPageState extends State<WorkoutCounterPage> {
  final WorkoutTimerService _timerService = WorkoutTimerService();
  int _secondsElapsed = 0;
  bool _isRunning = false;
  String? _selectedActivityType; // 'walking' or 'running'
  String? _runningPace; // 'slow', 'medium', 'fast'
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  double _weightKg = 70; // default fallback
  
  @override
  void initState() {
    super.initState();
    _loadUsernameAndCheckDay();
    // Prefill selections if provided
    _selectedActivityType = widget.initialActivityType;
    _runningPace = widget.initialRunningPace;
    _timerService.elapsedSeconds.addListener(_onTick);
    if (_selectedActivityType == 'running' && _runningPace != null && !_timerService.isRunning) {
      // Auto start for running when pace provided
      _timerService.start(activity: 'running', pace: _runningPace, weight: _weightKg);
      _isRunning = true;
    }
    if (_timerService.isRunning) {
      // Resume UI state from service
      _selectedActivityType = _timerService.activityType;
      _runningPace = _timerService.runningPace;
      _isRunning = true;
    }
  }

  Future<void> _loadUsernameAndCheckDay() async {
    // Get username from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    
    if (username.isNotEmpty) {
      await _historyService.checkAndResetIfNewDay(username);
      final profile = await ProfileService().getProfile(username);
      if (profile['hasProfile'] == true && profile['weight'] is double) {
        _weightKg = profile['weight'] as double;
      }
    }
  }

  @override
  void dispose() {
    _timerService.elapsedSeconds.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    setState(() {
      _secondsElapsed = _timerService.elapsedSeconds.value;
    });
  }

  void _startTimer() {
    if (_selectedActivityType == null) return;
    if (!_timerService.isRunning) {
      _timerService.start(activity: _selectedActivityType!, pace: _runningPace, weight: _weightKg);
    }
    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timerService.pause();
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _stopTimer() async {
    final total = _timerService.stop();
    _secondsElapsed = total;
    await _saveWorkoutTime();
    _showWorkoutCompleted();
  }

  Future<void> _saveWorkoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    
    if (username.isNotEmpty) {
      final minutes = _secondsElapsed ~/ 60;
      await _historyService.saveTodayWorkoutTime(username, minutes);
      
      // Save calories
      final calories = _calculateCalories();
      if (calories > 0) {
        await _historyService.saveTodayCalories(username, calories);
      }
    }
  }

  void _showWorkoutCompleted() {
    final minutes = _secondsElapsed ~/ 60;
    final seconds = _secondsElapsed % 60;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Antrenmanınızı tamamladınız!'),
            const SizedBox(height: 16),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (_selectedActivityType == 'walking')
              Text(
                'Adım: ${_calculateSteps()}',
                style: const TextStyle(fontSize: 18),
              ),
            if (_selectedActivityType == 'running')
              Text(
                'Mesafe: ${_calculateDistance()} metre',
                style: const TextStyle(fontSize: 18),
              ),
            if (_calculateCalories() > 0)
              Text(
                'Yakılan Kalori: ${_calculateCalories().toStringAsFixed(0)} kcal',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  int _calculateSteps() {
    final minutes = _secondsElapsed / 60;
    return (minutes * 115).round(); // Ortalama 115 adım/dakika
  }

  double _calculateDistance() {
    final minutes = _secondsElapsed / 60;
    if (_runningPace == 'slow') {
      return (minutes * 133).roundToDouble(); // 133 metre/dakika
    } else if (_runningPace == 'medium') {
      return (minutes * 167).roundToDouble(); // 167 metre/dakika
    } else if (_runningPace == 'fast') {
      return (minutes * 200).roundToDouble(); // 200 metre/dakika
    }
    return 0;
  }

  double _calculateCalories() {
    final minutes = _secondsElapsed / 60;
    double metValue = 0;
    
    if (_selectedActivityType == 'running') {
      if (_runningPace == 'slow') {
        metValue = 7.0;
      } else if (_runningPace == 'medium') {
        metValue = 10.0;
      } else if (_runningPace == 'fast') {
        metValue = 12.8;
      }
    } else if (_selectedActivityType == 'weightlifting') {
      metValue = 6.0;
    }
    
    if (metValue > 0) {
      // MET formula: {[MET x (Weight x 3.5)] / 200} x Time
      return ((metValue * (_weightKg * 3.5)) / 200) * minutes;
    }
    return 0;
  }

  String _getFormattedTime() {
    final minutes = _secondsElapsed ~/ 60;
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayWorkout?.dayName ?? 'Antrenman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Display
                Text(
                  _getFormattedTime(),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // Activity Type Selection (if not started)
                if (!_isRunning && _selectedActivityType == null)
                  Column(
                    children: [
                      Text(
                        'Antrenman Tipini Seç',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ActivityButton(
                        icon: Icons.directions_walk,
                        title: 'Yürüyüş',
                        onTap: () {
                          setState(() {
                            _selectedActivityType = 'walking';
                          });
                        },
                        isDarkMode: widget.isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _ActivityButton(
                        icon: Icons.directions_run,
                        title: 'Koşu',
                        onTap: () {
                          setState(() {
                            _selectedActivityType = 'running';
                          });
                        },
                        isDarkMode: widget.isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      if (widget.dayWorkout != null)
                        _ActivityButton(
                          icon: Icons.fitness_center,
                          title: 'Ağırlık Antrenmanı',
                        onTap: () {
                            setState(() {
                              _selectedActivityType = 'weightlifting';
                            });
                          },
                          isDarkMode: widget.isDarkMode,
                        ),
                    ],
                  ),

                // Running Pace Selection
                if (!_isRunning && _selectedActivityType == 'running' && _runningPace == null)
                  Column(
                    children: [
                      Text(
                        'Koşu Temposu Seç',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PaceButton(
                        title: 'Hafif',
                        subtitle: '~133m/dk',
                        onTap: () {
                          setState(() {
                            _runningPace = 'slow';
                          });
                          _startTimer();
                        },
                        isDarkMode: widget.isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _PaceButton(
                        title: 'Orta',
                        subtitle: '~167m/dk',
                        onTap: () {
                          setState(() {
                            _runningPace = 'medium';
                          });
                          _startTimer();
                        },
                        isDarkMode: widget.isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _PaceButton(
                        title: 'Tempolu',
                        subtitle: '~200m/dk',
                        onTap: () {
                          setState(() {
                            _runningPace = 'fast';
                          });
                          _startTimer();
                        },
                        isDarkMode: widget.isDarkMode,
                      ),
                    ],
                  ),

                // Workout Info
                if (_isRunning || (_selectedActivityType != null && _selectedActivityType != 'running') || (_runningPace != null))
                  Column(
                    children: [
                      if (_selectedActivityType == 'walking')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Adım: ${_calculateSteps()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      if (_selectedActivityType == 'running' && _runningPace != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Mesafe: ${_calculateDistance().toStringAsFixed(0)} metre',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kalori: ${_calculateCalories().toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedActivityType == 'weightlifting' && _isRunning)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Kalori: ${_calculateCalories().toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 60),

                // Control Buttons
                if (_timerService.elapsedSeconds.value == 0 && !_isRunning && _selectedActivityType != null && (_selectedActivityType != 'running' || _runningPace != null))
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow, size: 32),
                      label: const Text(
                        'Başlat',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                if (_isRunning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _pauseTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Duraklat'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _stopTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Bitir'),
                        ),
                      ),
                    ],
                  ),
                
                if (!_isRunning && _timerService.elapsedSeconds.value > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            _timerService.resume();
                            setState(() {
                              _isRunning = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Devam Et'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _stopTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Bitir'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ActivityButton({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF6B35),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B35), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF6B35), size: 20),
          ],
        ),
      ),
    );
  }
}

class _PaceButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _PaceButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

