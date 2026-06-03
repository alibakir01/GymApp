import 'dart:async';
import 'package:flutter/foundation.dart';

class WorkoutTimerService {
  static final WorkoutTimerService _instance = WorkoutTimerService._internal();
  factory WorkoutTimerService() => _instance;
  WorkoutTimerService._internal();

  final ValueNotifier<int> elapsedSeconds = ValueNotifier<int>(0);
  bool _isRunning = false;
  String? activityType; // walking | running | weightlifting
  String? runningPace; // slow | medium | fast
  double? _weightKg;

  Timer? _timer;
  DateTime? _startTime;

  bool get isRunning => _isRunning;

  void setWeight(double weight) {
    _weightKg = weight;
  }

  double getCurrentCalories() {
    if (_weightKg == null || elapsedSeconds.value == 0) return 0;
    
    final minutes = elapsedSeconds.value / 60;
    double metValue = 0;
    
    if (activityType == 'running') {
      if (runningPace == 'slow') {
        metValue = 7.0;
      } else if (runningPace == 'medium') {
        metValue = 10.0;
      } else if (runningPace == 'fast') {
        metValue = 12.8;
      }
    } else if (activityType == 'weightlifting') {
      metValue = 6.0;
    }
    
    if (metValue > 0) {
      return ((metValue * (_weightKg! * 3.5)) / 200) * minutes;
    }
    return 0;
  }

  void start({required String activity, String? pace, int initialSeconds = 0, double? weight}) {
    activityType = activity;
    runningPace = pace;
    _weightKg = weight;
    _isRunning = true;
    _startTime = DateTime.now().subtract(Duration(seconds: initialSeconds));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        elapsedSeconds.value = DateTime.now().difference(_startTime!).inSeconds;
      }
    });
  }

  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer?.cancel();
  }

  void resume() {
    if (_isRunning || _startTime == null) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        elapsedSeconds.value = DateTime.now().difference(_startTime!).inSeconds;
      }
    });
  }

  int stop() {
    _timer?.cancel();
    _isRunning = false;
    final total = elapsedSeconds.value;
    elapsedSeconds.value = 0;
    _startTime = null;
    activityType = null;
    runningPace = null;
    _weightKg = null;
    return total;
  }
}








