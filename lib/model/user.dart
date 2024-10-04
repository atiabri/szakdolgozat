import 'package:sqflite/sqflite.dart';

class User {
  int? id;
  String fullName;
  String username;
  String password;
  DateTime birthDate;
  String gender;
  double weight;
  double height;
  String level; // Új mező a szinthez

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.height,
    required this.level, // Új mező a konstruktorban
  });

  // Convert a User object to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'password': password,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'level': level, // Új mező a mapban
    };
  }

  // Convert a Map to a User object
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['full_name'],
      username: map['username'],
      password: map['password'],
      birthDate: DateTime.parse(map['birth_date']),
      gender: map['gender'],
      weight: map['weight'],
      height: map['height'],
      level: map['level'], // Új mező beolvasása
    );
  }

  // Insert a User into the database
  static Future<void> insertUser(Database db, User user) async {
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve a User by username
  static Future<User?> getUserByUsername(Database db, String username) async {
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}
