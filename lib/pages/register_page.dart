import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(String) onRegisterSuccess;

  const RegisterPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _usernameTaken = false;
  bool _isCheckingUsername = false;

  Future<void> _checkUsername() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameTaken = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    final taken = await _authService.isUsernameTaken(_usernameController.text);

    setState(() {
      _usernameTaken = taken;
      _isCheckingUsername = false;
    });
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurunuz');
      return;
    }

    if (_usernameTaken) {
      _showError('Bu kullanıcı adı zaten alınmış');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError('Geçerli bir e-posta adresi giriniz');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Şifre en az 6 karakter olmalıdır');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = User(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    final success = await _authService.registerUser(user);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSuccess('Kayıt başarılı! Giriş yapılıyor...');
      await Future.delayed(const Duration(seconds: 1));
      widget.onRegisterSuccess(_usernameController.text);
    } else {
      _showError('Bu kullanıcı adı zaten alınmış');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Theme toggle button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: widget.toggleTheme,
                      icon: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: const Color(0xFFFF6B35),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logo or Icon
                  Container(
                    width: 80,
                    height: 80,
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
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-posta',
                      prefixIcon: const Icon(Icons.email_outlined),
                      prefixIconColor: const Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username field with availability check
                  TextField(
                    controller: _usernameController,
                    onChanged: (_) => _checkUsername(),
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı Adı',
                      prefixIcon: const Icon(Icons.person_outline),
                      prefixIconColor: const Color(0xFFFF6B35),
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                ),
                              ),
                            )
                          : _usernameController.text.isNotEmpty
                              ? Icon(
                                  _usernameTaken ? Icons.cancel : Icons.check_circle,
                                  color: _usernameTaken ? Colors.red : Colors.green,
                                )
                              : null,
                      errorText: _usernameTaken && _usernameController.text.isNotEmpty
                          ? 'Bu kullanıcı adı zaten alınmış'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Şifre (en az 6 karakter)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      prefixIconColor: const Color(0xFFFF6B35),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _usernameTaken || _isCheckingUsername)
                          ? null
                          : _register,
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
                              'Kayıt Ol',
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
}

