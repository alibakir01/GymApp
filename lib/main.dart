import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_setup_page.dart';
import 'services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _checkLoginStatus();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // Handle auto-login
    }
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFF1B1B1B),
          surface: Colors.white,
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFF1B1B1B),
          surface: Color(0xFF2C2C2C),
          background: Color(0xFF1B1B1B),
        ),
        scaffoldBackgroundColor: const Color(0xFF1B1B1B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1B1B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoggedIn = false;
  String _loggedInUsername = '';
  bool _hasProfile = false;
  bool _isCheckingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final username = prefs.getString('username') ?? '';
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _loggedInUsername = username;
    });

    if (isLoggedIn && username.isNotEmpty) {
      final profileService = ProfileService();
      final hasProfile = await profileService.hasProfile(username);
      setState(() {
        _hasProfile = hasProfile;
        _isCheckingProfile = false;
      });
    } else {
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

  void _updateLoginStatus(bool isLoggedIn, String username) async {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _loggedInUsername = username;
    });

    if (isLoggedIn && username.isNotEmpty) {
      final profileService = ProfileService();
      final hasProfile = await profileService.hasProfile(username);
      setState(() {
        _hasProfile = hasProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      if (!_hasProfile) {
        return ProfileSetupPage(
          username: _loggedInUsername,
          onComplete: () {
            setState(() {
              _hasProfile = true;
            });
          },
        );
      }

      return HomePage(
        username: _loggedInUsername,
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
      );
    }
    
    return LoginPage(
      toggleTheme: widget.toggleTheme,
      isDarkMode: widget.isDarkMode,
      onLoginSuccess: (username) {
        _updateLoginStatus(true, username);
      },
    );
  }
}

