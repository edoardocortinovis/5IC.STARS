import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Importa hive_flutter

// Rimuovi gli import di sqflite
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_ffi_web;

import 'access_section/registration_page.dart';
import 'access_section/access_page.dart';
import 'home_page.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart'; // Importa il tuo modello User

const String userBoxName = 'users'; // Nome del box Hive per gli utenti

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Hive per Flutter
  await Hive.initFlutter();

  // Registra il TypeAdapter per il modello User
  Hive.registerAdapter(UserAdapter());

  // Apri i box Hive che utilizzerai
  await Hive.openBox<User>(userBoxName);
  // Potresti aprire un box per le preferenze generali se vuoi migrare anche SharedPreferences
  // await Hive.openBox('settings');

  // Controlla lo stato di login usando AuthService (che ora userà Hive o SharedPreferences)
  final AuthService authService =
      AuthService(); // AuthService sarà aggiornato per usare Hive
  final bool isLoggedIn =
      await authService
          .isLoggedIn(); // Questo metodo in AuthService deve essere aggiornato

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  // final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>(); // Mantieni se necessario

  MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5IC Stars App',
      debugShowCheckedModeBanner: false,
      // navigatorKey: _navigatorKey, // Mantieni se necessario
      theme: ThemeData(
        // Il tuo tema rimane invariato
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E17EB),
          brightness: Brightness.light,
          primary: const Color(0xFF5E17EB),
          secondary: const Color(0xFF00A2FF),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          error: Colors.redAccent,
          onError: Colors.white,
          background: const Color(0xFFF0F2F5),
          onBackground: Colors.black87,
          surfaceVariant: Colors.grey.shade200,
          outline: Colors.grey.shade400,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          bodyLarge: GoogleFonts.poppins(fontSize: 16),
          bodyMedium: GoogleFonts.poppins(fontSize: 14),
          headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: const Color(0xFF5E17EB),
          ),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E17EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 2),
          ),
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
          prefixIconColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.focused)) {
              return const Color(0xFF5E17EB);
            }
            if (states.contains(MaterialState.error)) {
              return Colors.redAccent;
            }
            return Colors.grey.shade600;
          }),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/register',
      routes: {
        '/register': (context) => const RegistrationPage(),
        '/login': (context) => const AccessPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

// Alla fine del file, prima che l'app si chiuda, potresti voler chiudere i box Hive.
// Questo è particolarmente importante su desktop, meno su mobile/web ma è buona pratica.
// Tuttavia, per semplicità, `Hive.initFlutter()` gestisce molto di questo.
// Se vuoi essere esplicito:
// WidgetsBinding.instance.addObserver(AppLifecycleObserver());
// class AppLifecycleObserver extends WidgetsBindingObserver {
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.detached) {
//       Hive.close();
//     }
//     super.didChangeAppLifecycleState(state);
//   }
// }
