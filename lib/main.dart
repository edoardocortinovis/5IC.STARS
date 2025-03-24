import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Importa le pagine necessarie
import 'access_section/RegistrationPage.dart';
import 'access_section/AccessPage.dart';
import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Controlla se l'utente è già loggato
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

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
      // Definisci le rotte dell'app
      initialRoute: isLoggedIn ? '/home' : '/register',
      routes: {
        '/register': (context) => const RegistrationPage(),
        //'/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
