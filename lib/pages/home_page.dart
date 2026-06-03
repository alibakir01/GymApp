import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/workout_service.dart';
import '../services/workout_history_service.dart';
import '../models/workout_plan.dart';
import 'workout_plan_page.dart';
import 'workout_notes_page.dart';
import 'workout_counter_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showStartWorkoutSheet(BuildContext context, String username, bool isDarkMode, VoidCallback toggleTheme) {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: Color(0xFFFF6B35)),
                  title: const Text('Ağırlık Antrenmanı'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => WorkoutCounterPage(
                          dayWorkout: null,
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                          initialActivityType: 'weightlifting',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_run, color: Color(0xFFFF6B35)),
                  title: const Text('Koşu Antrenmanı'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final pace = await showModalBottomSheet<String>(
                      context: parentContext,
                      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (paceSheetContext) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Hafif (~133 m/dk)'),
                                onTap: () => Navigator.pop(paceSheetContext, 'slow'),
                              ),
                              ListTile(
                                title: const Text('Orta (~167 m/dk)'),
                                onTap: () => Navigator.pop(paceSheetContext, 'medium'),
                              ),
                              ListTile(
                                title: const Text('Tempolu (~200 m/dk)'),
                                onTap: () => Navigator.pop(paceSheetContext, 'fast'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    if (pace != null) {
                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(
                          builder: (_) => WorkoutCounterPage(
                            dayWorkout: null,
                            toggleTheme: toggleTheme,
                            isDarkMode: isDarkMode,
                            initialActivityType: 'running',
                            initialRunningPace: pace,
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_walk, color: Color(0xFFFF6B35)),
                  title: const Text('Yürüyüş'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => WorkoutCounterPage(
                          dayWorkout: null,
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                          initialActivityType: 'walking',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDietProgramSheet(BuildContext context, bool isDarkMode) {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Hazır diyet programları: yakında.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hazır Diyet Programları', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Kendi diyet programını oluştur: yakında.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                      foregroundColor: isDarkMode ? Colors.white : const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Kendi Diyet Programını Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final username = widget.username;
    final toggleTheme = widget.toggleTheme;
    final isDarkMode = widget.isDarkMode;
    final surfaceColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : Colors.black;
    final textSecondary = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1B1B1B) : Colors.white,
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Ağırlık Not Defteri',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutNotesPage(
                    username: username,
                    toggleTheme: toggleTheme,
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
            tooltip: isDarkMode ? 'Aydınlık tema' : 'Karanlık tema',
          ),
        ],
      ),
      body: Container
        (
        width: double.infinity,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero header with BMI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A5B), Color(0xFFFF6B35)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.fitness_center, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hoş geldin',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Hazır mısın?', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: ProfileService().getProfile(username),
                      builder: (context, snapshot) {
                        final hasProfile = (snapshot.data ?? const {'hasProfile': false})['hasProfile'] == true;
                        if (!hasProfile) {
                          return const SizedBox.shrink();
                        }
                        final height = snapshot.data!['height'] as double;
                        final weight = snapshot.data!['weight'] as double;
                        final bmi = ProfileService.calculateBMI(height, weight);
                        final category = ProfileService.getBMICategory(bmi);
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monitor_weight, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'VKİ ${bmi.toStringAsFixed(1)} • $category',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _TodayStats(username: username, isDarkMode: isDarkMode),

              const SizedBox(height: 20),

              _TodaysWorkoutCard(
                username: username,
                isDarkMode: isDarkMode,
                onOpenPlan: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlanPage(
                        username: username,
                        toggleTheme: toggleTheme,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Hızlı Erişim',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Planlarım ve Notlar alt alta bar şeklinde
              _SurfaceCard(
                color: surfaceColor,
                child: _IconTile(
                  icon: Icons.fitness_center,
                  title: 'Planlar',
                  subtitle: 'Programını yönet',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutPlanPage(
                          username: username,
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  isDarkMode: isDarkMode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _SurfaceCard(
                color: surfaceColor,
                child: _IconTile(
                  icon: Icons.note_alt_outlined,
                  title: 'Notlar',
                  subtitle: 'Ağırlıklarını kaydet',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutNotesPage(
                          username: username,
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  isDarkMode: isDarkMode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _SurfaceCard(
                color: surfaceColor,
                child: _IconTile(
                  icon: Icons.restaurant_menu,
                  title: 'Diyet Programı',
                  subtitle: 'Beslenme planını yönet',
                  onTap: () {
                    _showDietProgramSheet(context, isDarkMode);
                  },
                  isDarkMode: isDarkMode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _showStartWorkoutSheet(context, username, isDarkMode, toggleTheme),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Antrenmanı Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// (Removed old standalone BMI card as BMI is now shown in the header)

class _TodaysWorkoutCard extends StatelessWidget {
  final String username;
  final bool isDarkMode;
  final VoidCallback onOpenPlan;

  const _TodaysWorkoutCard({
    required this.username,
    required this.isDarkMode,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutPlan?>(
      future: WorkoutService().getWorkoutPlan(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeleton(height: 180);
        }
        final plan = snapshot.data;
        if (plan == null || plan.dayWorkouts.isEmpty) {
          return _highlightCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badgeIcon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      'Bugünkü Antrenman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Henüz bir planınız yok. Plan oluşturun veya mevcut planınızı açın.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: onOpenPlan,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Planı Aç'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final todays = _pickToday(plan);
        return _highlightCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badgeIcon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bugünkü Antrenman',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : const Color(0xFFFF6B35)).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      todays.dayName,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...todays.muscleGroups.map((mg) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mg.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: mg.exercises
                              .map((e) => Chip(
                                    label: Text(
                                      '${e.name} ${e.sets}x${e.reps}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    backgroundColor: (isDarkMode ? Colors.white : const Color(0xFFFF6B35)).withOpacity(0.10),
                                    side: BorderSide(color: (isDarkMode ? Colors.white : const Color(0xFFFF6B35)).withOpacity(0.25)),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onOpenPlan,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Planı Aç'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  DayWorkout _pickToday(WorkoutPlan plan) {
    final days = plan.dayWorkouts;
    if (days.isEmpty) return DayWorkout(dayNumber: 0, dayName: 'Gün', muscleGroups: const []);
    final weekday = DateTime.now().weekday; // 1..7
    final idx = (weekday - 1) % days.length;
    return days[idx];
  }

  Widget _skeleton({double height = 160}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _highlightCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.25),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _badgeIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
    );
  }
}

class _TodayStats extends StatelessWidget {
  final String username;
  final bool isDarkMode;

  const _TodayStats({required this.username, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final surface = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final primary = isDarkMode ? Colors.white : Colors.black;
    final secondary = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return FutureBuilder<int>(
      future: WorkoutHistoryService().getTodayWorkoutTime(username),
      builder: (context, snapshot) {
        final minutes = snapshot.data ?? 0;
        final calories = (minutes * 6).toInt();
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_fire_department, color: Color(0xFFFF6B35)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kalori', style: TextStyle(color: secondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('$calories kcal', style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time, color: Color(0xFFFF6B35)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Süre', style: TextStyle(color: secondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${minutes} dk', style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Color color;
  final Widget child;

  const _SurfaceCard({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDarkMode;
  final Color? textPrimary;
  final Color? textSecondary;

  const _IconTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDarkMode,
    this.textPrimary,
    this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : const Color(0xFFFF6B35)).withOpacity(isDarkMode ? 0.1 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey)
        ],
      ),
    );
  }
}



