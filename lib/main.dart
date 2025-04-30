import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Import necessary pages
import 'access_section/registration_page.dart';
import 'access_section/access_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5IC Stars App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E17EB),
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      // Define app routes
      initialRoute: isLoggedIn ? '/home' : '/register',
      routes: {
        '/register': (context) => const RegistrationPage(),
        '/login': (context) => const AccessPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
