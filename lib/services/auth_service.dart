import 'dart:convert'; // Per utf8.encode
import 'package:crypto/crypto.dart'; // Per sha256
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive_flutter/hive_flutter.dart'; // Se usi Hive per le impostazioni

import '../models/user_model.dart';
import './user_data_service.dart';
import 'dart:math'; // Per generare un ID

class AuthService {
  final UserDataService _userDataService = UserDataService();
  // static const String _appSalt = "TUA_APP_SALT_SEGRETA_E_UNICA_QUI"; // IMPORTANTE: Cambia questo!

  // AuthService() {
  //   // Hive per settings se lo usi
  // }

  String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }

  // Funzione helper per hashare la password con SHA256 e un salt
  // In un'app reale, il salt dovrebbe essere generato casualmente PER OGNI UTENTE
  // e salvato insieme alla password hashata.
  // Per questo esempio, useremo un salt "statico" dall'email, che è MEGLIO di nessun salt,
  // ma NON ideale come un salt casuale per utente.
  String _hashPassword(String password, String emailSalt) {
    // Combina la password con un salt derivato dall'email (o un altro identificatore unico dell'utente)
    // Questo rende gli hash diversi anche per la stessa password se usata da utenti diversi.
    // ATTENZIONE: questo NON è un salt crittograficamente forte come quello generato da bcrypt.
    final String saltedPassword =
        password + emailSalt.toLowerCase(); // Usa l'email come parte del salt
    final List<int> bytes = utf8.encode(saltedPassword);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final String trimmedEmail = email.trim();
      final String trimmedUsername = username.trim();

      if (_userDataService.getUserByEmail(trimmedEmail) != null) {
        return {'success': false, 'message': 'Questa email è già registrata.'};
      }
      if (_userDataService.getUserByUsername(trimmedUsername) != null) {
        return {'success': false, 'message': 'Questo username è già in uso.'};
      }

      // Usa l'email (o parte di essa) come "salt" per questo esempio.
      // In produzione, genera un salt casuale per ogni utente e salvalo.
      final String hashedPassword = _hashPassword(password, trimmedEmail);

      final newUser = User(
        id: _generateRandomId(),
        username: trimmedUsername,
        email: trimmedEmail,
        password: hashedPassword, // Salva la password hashata con SHA256
        createdAt: DateTime.now(),
      );

      await _userDataService.saveUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', newUser.username);

      return {
        'success': true,
        'message': 'Registrazione avvenuta con successo!',
      };
    } catch (e, s) {
      print('Errore in AuthService.registerUser: $e');
      print(s);
      return {
        'success': false,
        'message': 'Errore durante la registrazione: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final String trimmedEmail = email.trim();
      final user = _userDataService.getUserByEmail(trimmedEmail);

      if (user == null) {
        return {'success': false, 'message': 'Email non trovata.'};
      }

      // Ricrea l'hash della password inserita usando lo stesso "salt" (email)
      final String hashedPasswordAttempt = _hashPassword(
        password,
        trimmedEmail,
      );

      if (user.password == hashedPasswordAttempt) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', user.username);

        return {
          'success': true,
          'message': 'Accesso effettuato con successo!',
          'username': user.username,
        };
      } else {
        return {'success': false, 'message': 'Password errata.'};
      }
    } catch (e, s) {
      print('Errore in AuthService.loginUser: $e');
      print(s);
      return {
        'success': false,
        'message': 'Errore durante l\'accesso: ${e.toString()}',
      };
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
