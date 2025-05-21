import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../main.dart'; // Per userBoxName

class UserDataService {
  late Box<User> _userBox;

  UserDataService() {
    _userBox = Hive.box<User>(userBoxName);
  }

  // Salva o aggiorna un utente.
  // Hive usa la chiave per determinare se aggiungere o aggiornare.
  // Useremo l'email come chiave per gli utenti.
  Future<void> saveUser(User user) async {
    // L'ID dell'utente nel modello può essere l'email o un UUID.
    // Per il box Hive, la chiave sarà l'email per facilitare la ricerca.
    await _userBox.put(user.email, user); // Usa l'email come chiave nel box
  }

  // Recupera un utente per email (che è la nostra chiave nel box)
  User? getUserByEmail(String email) {
    return _userBox.get(email);
  }

  // Recupera un utente per username (richiede un'iterazione)
  User? getUserByUsername(String username) {
    for (var user in _userBox.values) {
      if (user.username == username) {
        return user;
      }
    }
    return null;
  }

  // (Opzionale) Recupera tutti gli utenti
  List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  // (Opzionale) Elimina un utente per email
  Future<void> deleteUser(String email) async {
    await _userBox.delete(email);
  }
}
