import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import 'create_custom_plan_page.dart';
import 'view_workout_plan_page.dart';
import 'premade_workout_plans_page.dart';
import 'my_programs_page.dart';

class WorkoutPlanPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const WorkoutPlanPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  @override
  Widget build(BuildContext context) {
    final username = widget.username;
    final toggleTheme = widget.toggleTheme;
    final isDarkMode = widget.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenman Planı'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FutureBuilder<bool>(
              future: WorkoutService().hasWorkoutPlan(username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final hasPlan = snapshot.data ?? false;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      hasPlan ? 'Antrenman Planınız' : 'Antrenman Planı Oluştur',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    if (hasPlan)
                      _ActionCard(
                        title: 'Mevcut Planınızı Görüntüle',
                        subtitle: 'Kaydedilmiş antrenman planınızı inceleyin',
                        icon: Icons.calendar_view_week,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewWorkoutPlanPage(
                                username: username,
                                toggleTheme: toggleTheme,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    _ActionCard(
                      title: 'Programlarım',
                      subtitle: 'Kaydettiğiniz programları görüntüleyin',
                      icon: Icons.bookmarks,
                      isDarkMode: isDarkMode,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProgramsPage(
                              username: username,
                              toggleTheme: toggleTheme,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Not defteri girişi kaldırıldı
                    _ActionCard(
                      title: 'Hazır Antrenman Planları',
                      subtitle: 'Profesyonellerce hazırlanmış planlardan birini seçin',
                      icon: Icons.library_books,
                      isDarkMode: isDarkMode,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PremadeWorkoutPlansPage(
                              username: username,
                              toggleTheme: toggleTheme,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        );
                        if (mounted && result == true) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _ActionCard(
                      title: 'Kendi Programını Oluştur',
                      subtitle: 'Kişiselleştirilmiş antrenman planı oluşturun',
                      icon: Icons.edit_note,
                      isDarkMode: isDarkMode,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateCustomPlanPage(
                              username: username,
                              toggleTheme: toggleTheme,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        );
                        if (mounted && result == true) {
                          setState(() {});
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFF6B35), size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFFF6B35),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

