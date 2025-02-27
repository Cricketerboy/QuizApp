import 'package:flutter/material.dart';
import 'package:quizapp/screens/admin_page.dart';
import 'package:quizapp/screens/login_page.dart';
import 'package:quizapp/screens/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugins are registered

  final prefs = await SharedPreferences.getInstance();
  final String? role = prefs.getString("role");

  runApp(MyApp(role: role));
}

class MyApp extends StatelessWidget {
  final String? role;

  MyApp({required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizApp',
      debugShowCheckedModeBanner: false,
      home: _getInitialPage(),
    );
  }

  Widget _getInitialPage() {
    if (role == "admin") {
      return AdminDashboard();
    } else if (role == "user") {
      return UserPage();
    } else {
      return LoginPage();
    }
  }
}
