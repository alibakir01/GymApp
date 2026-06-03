import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileSetupPage extends StatefulWidget {
  final String username;
  final VoidCallback onComplete;

  const ProfileSetupPage({
    super.key,
    required this.username,
    required this.onComplete,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  double _calculatedBMI = 0;
  String _bmiCategory = '';

  @override
  void initState() {
    super.initState();
    _calculateBMI();
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      setState(() {
        _calculatedBMI = ProfileService.calculateBMI(height, weight);
        _bmiCategory = ProfileService.getBMICategory(_calculatedBMI);
      });
    } else {
      setState(() {
        _calculatedBMI = 0;
        _bmiCategory = '';
      });
    }
  }

  String? _selectedGoal = null;
  String? _selectedGender = null;
  late TextEditingController _targetWeightController = TextEditingController();
  late TextEditingController _bodyFatController = TextEditingController();
  late TextEditingController _targetBodyFatController = TextEditingController();

  Future<void> _saveProfile() async {
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ageController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurunuz');
      return;
    }

    if (_selectedGender == null) {
      _showError('Lütfen cinsiyet seçiniz');
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
      _isLoading = true;
    });

    final success = await _profileService.saveProfile(
      widget.username,
      height,
      weight,
      age,
      goal: _selectedGoal,
      gender: _selectedGender,
      targetWeight: double.tryParse(_targetWeightController.text),
      bodyFat: double.tryParse(_bodyFatController.text),
      targetBodyFat: double.tryParse(_targetBodyFatController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      widget.onComplete();
    } else {
      _showError('Profil kaydedilirken bir hata oluştu');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button (disabled for first time)
                  const SizedBox(height: 40),

                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6B35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Profil Bilgileriniz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vücut kitle indeksinizi hesaplayabilmemiz için\naşağıdaki bilgileri doldurun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Height field
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBMI(),
                    decoration: InputDecoration(
                      hintText: 'Boy (cm)',
                      prefixIcon: const Icon(Icons.height),
                      prefixIconColor: const Color(0xFFFF6B35),
                      suffixText: 'cm',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight field
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBMI(),
                    decoration: InputDecoration(
                      hintText: 'Kilo (kg)',
                      prefixIcon: const Icon(Icons.monitor_weight),
                      prefixIconColor: const Color(0xFFFF6B35),
                      suffixText: 'kg',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Age field
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Yaş',
                      prefixIcon: const Icon(Icons.cake),
                      prefixIconColor: const Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gender selector
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton('Erkek', 'Erkek', Icons.male, isDarkMode),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderButton('Kadın', 'Kadın', Icons.female, isDarkMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // BMI Display
                  if (_calculatedBMI > 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF6B35),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Vücut Kitle İndeksiniz',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _calculatedBMI.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _bmiCategory,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_calculatedBMI > 0)                   const SizedBox(height: 24),

                  // Training Goal
                  Text(
                    'Antrenman Amacı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Goal selectors
                  Row(
                    children: [
                      Expanded(
                        child: _buildGoalButton('Cut', 'Cut', isDarkMode),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGoalButton('Bulk', 'Bulk', isDarkMode),
                      ),
                    ],
                  ),
                  
                  if (_selectedGoal != null && _selectedGoal!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetWeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Hedef Kilo (kg)',
                        prefixIcon: const Icon(Icons.flag),
                        prefixIconColor: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bodyFatController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Yağ Oranı (%)',
                        prefixIcon: const Icon(Icons.percent),
                        prefixIconColor: const Color(0xFFFF6B35),
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
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kaydet ve Devam Et',
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
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, String label, IconData icon, bool isDarkMode) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF6B35)
              : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFFFF6B35)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalButton(String goal, String label, bool isDarkMode) {
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
              ? const Color(0xFFFF6B35)
              : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

