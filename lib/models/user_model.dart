import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Questo file sarà generato

@HiveType(typeId: 0) // Assegna un typeId univoco per ogni classe HiveObject
class User extends HiveObject {
  // Estendi HiveObject per salvare direttamente l'oggetto
  @HiveField(0)
  late String id; // Useremo l'email come ID univoco per semplicità con Hive, o un UUID

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String email; // L'email sarà la chiave primaria nel box utenti

  @HiveField(3)
  late String password; // Ricorda: questa sarà la password HASHATA

  @HiveField(4)
  DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
  });
}
