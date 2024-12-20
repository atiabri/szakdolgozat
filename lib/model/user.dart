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
  String level;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.height,
    required this.level,
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
      'level': level,
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
      level: map['level'],
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

  // Retrieve a User by ID
  static Future<User?> getUserById(Database db, int userId) async {
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}
