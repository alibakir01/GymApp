import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfileSettingsPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _targetWeightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _targetBodyFatController;
  
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedGoal;
  double _originalBMI = 0;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _ageController = TextEditingController();
    _targetWeightController = TextEditingController();
    _bodyFatController = TextEditingController();
    _targetBodyFatController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await _profileService.getProfile(widget.username);

    setState(() {
      _isLoading = false;
      if (profile['hasProfile']) {
        _heightController.text = profile['height'].toString();
        _weightController.text = profile['weight'].toString();
        _ageController.text = profile['age'].toString();
        _selectedGoal = profile['goal'] as String?;
        _targetWeightController.text = profile['targetWeight']?.toString() ?? '';
        _bodyFatController.text = profile['bodyFat']?.toString() ?? '';
        _targetBodyFatController.text = profile['targetBodyFat']?.toString() ?? '';
        _originalBMI = ProfileService.calculateBMI(
          profile['height'],
          profile['weight'],
        );
      }
    });
  }

  void _calculateBMI() {
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ageController.text.isEmpty) {
      _showError('Lütfen zorunlu alanları doldurunuz (Boy, Kilo, Yaş)');
      return;
    }

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);

    if (height == null || height <= 0 || height > 250) {
      _showError('Geçerli bir boy değeri giriniz (cm)');
      return;
    }

    if (weight == null || weight <= 0 || weight > 300) {
      _showError('Geçerli bir kilo değeri giriniz (kg)');
      return;
    }

    if (age == null || age <= 0 || age > 150) {
      _showError('Geçerli bir yaş değeri giriniz');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await _profileService.updateProfile(
      widget.username,
      height,
      weight,
      age,
      goal: _selectedGoal,
      targetWeight: double.tryParse(_targetWeightController.text),
      bodyFat: double.tryParse(_bodyFatController.text),
      targetBodyFat: double.tryParse(_targetBodyFatController.text),
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      setState(() {
        _originalBMI = ProfileService.calculateBMI(height, weight);
      });
      _showSuccess('Profil başarıyla güncellendi!');
    } else {
      _showError('Profil güncellenirken bir hata oluştu');
    }
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
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    _bodyFatController.dispose();
    _targetBodyFatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
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
                  children: [
                    // BMI Visualization
                    if (_originalBMI > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Vücut Kitle İndeksiniz',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _originalBMI.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ProfileService.getBMICategory(_originalBMI),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Body figure visualization
                            _buildBodyFigure(_originalBMI),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Basic Info
                    _buildSectionTitle('Temel Bilgiler'),
                    
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                      decoration: InputDecoration(
                        hintText: 'Boy (cm)',
                        prefixIcon: const Icon(Icons.height),
                        prefixIconColor: const Color(0xFFFF6B35),
                        suffixText: 'cm',
                        filled: true,
                        fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                      decoration: InputDecoration(
                        hintText: 'Kilo (kg)',
                        prefixIcon: const Icon(Icons.monitor_weight),
                        prefixIconColor: const Color(0xFFFF6B35),
                        suffixText: 'kg',
                        filled: true,
                        fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Yaş',
                        prefixIcon: const Icon(Icons.cake),
                        prefixIconColor: const Color(0xFFFF6B35),
                        filled: true,
                        fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Training Goal
                    _buildSectionTitle('Antrenman Amacı'),
                    
                    _buildGoalSelector(),
                    
                    if (_selectedGoal != null && _selectedGoal!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      
                      if (_selectedGoal == 'Cut' || _selectedGoal == 'Bulk') ...[
                        TextField(
                          controller: _targetWeightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Hedef Kilo (kg)',
                            prefixIcon: const Icon(Icons.flag),
                            prefixIconColor: const Color(0xFFFF6B35),
                            suffixText: 'kg',
                            filled: true,
                            fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextField(
                        controller: _bodyFatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Mevcut Yağ Oranı (%)',
                          prefixIcon: const Icon(Icons.percent),
                          prefixIconColor: const Color(0xFFFF6B35),
                          suffixText: '%',
                          filled: true,
                          fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _targetBodyFatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Hedef Yağ Oranı (%)',
                          prefixIcon: const Icon(Icons.track_changes),
                          prefixIconColor: const Color(0xFFFF6B35),
                          suffixText: '%',
                          filled: true,
                          fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
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
                                'Kaydet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      children: [
        _buildGoalOption('Cut', 'Kilo verme ve yağ yakma', Icons.trending_down),
        const SizedBox(height: 12),
        _buildGoalOption('Bulk', 'Kilo alma ve kas yapma', Icons.trending_up),
        const SizedBox(height: 12),
        _buildGoalOption('Maintain', 'Mevcut formu koruma', Icons.straighten),
      ],
    );
  }

  Widget _buildGoalOption(String goal, String description, IconData icon) {
    final isSelected = _selectedGoal == goal;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = goal;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF6B35).withOpacity(0.2)
              : (widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF6B35) : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFFF6B35)),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyFigure(double bmi) {
    // Body image based on BMI
    Color colorFilter;
    
    if (bmi < 18.5) {
      colorFilter = Colors.blue; // Underweight
    } else if (bmi < 25) {
      colorFilter = Colors.green; // Normal
    } else if (bmi < 30) {
      colorFilter = Colors.orange; // Overweight
    } else {
      colorFilter = Colors.red; // Obese
    }
    
    return Container(
      height: 150,
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          colorFilter.withOpacity(0.8),
          BlendMode.srcATop,
        ),
        child: Image.asset(
          'assets/images/body.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image not found - show simple icons
            return _buildFallbackBodyFigure(colorFilter);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackBodyFigure(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBodySegment('Baş', Icons.circle_outlined, color, 10),
          _buildBodySegment('Gövde', Icons.square, color, 20),
          _buildBodySegment('Bacak', Icons.vertical_align_bottom, color, 25),
        ],
      ),
    );
  }

  Widget _buildBodySegment(String label, IconData icon, Color color, double size) {
    return Column(
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

