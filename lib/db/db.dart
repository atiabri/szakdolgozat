import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:onlab_final/model/entry.dart';

abstract class DB {
  static Database? _db;
  static int get _version => 1;

  // Initialize the database
  static Future<void> init() async {
    try {
      String _path = await getDatabasesPath();
      String _dbpath = p.join(_path, 'database.db');
      print('Opening database at path: $_dbpath'); // Debug message
      _db = await openDatabase(_dbpath, version: _version, onCreate: onCreate);
      print('Database initialized'); // Debug message
    } catch (ex) {
      print('Error initializing database: $ex'); // Debug message
    }
  }

  // Create tables
  static FutureOr<void> onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE entries ( 
          id INTEGER PRIMARY KEY NOT NULL, 
          user_id INTEGER, 
          date STRING, 
          duration STRING, 
          speed REAL, 
          distance REAL, 
          speed_per_km TEXT, 
          elevation_gain REAL, 
          FOREIGN KEY(user_id) REFERENCES users(id) 
        ) 
      ''');

      print('Table "entries" created'); // Debug message

      await db.execute('''
        CREATE TABLE users ( 
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          full_name TEXT, 
          username TEXT UNIQUE, 
          password TEXT, 
          birth_date TEXT, 
          gender TEXT, 
          height REAL, 
          weight REAL, 
          level TEXT 
        ) 
      ''');

      print('Table "users" created'); // Debug message
    } catch (ex) {
      print('Error creating tables: $ex'); // Debug message
    }
  }

  // Provide a method to access the database instance
  static Future<Database> getDatabase() async {
    if (_db == null) {
      print('Database not initialized, calling init()'); // Debug message
      await init();
    }
    return _db!;
  }

  // Insert data into a table
  static Future<int> insert(String table, Map<String, dynamic> item) async {
    final db = await getDatabase();

    // Debug message: display the item to be inserted
    print('Inserting into table: $table, Item: $item');

    int result = await db.insert(table, item,
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Debug message: check the result of the insert
    print('Insert result: $result');

    return result;
  }

  // Query data from a table
  static Future<List<Map<String, dynamic>>> query(String table,
      {int? userId}) async {
    final db = await getDatabase();

    // Debug message: display the query and filter
    print('Querying table: $table for user_id: $userId');

    if (userId != null) {
      return await db.query(
        table,
        where: 'user_id = ?',
        whereArgs: [userId], // Filter by user_id
      );
    } else {
      return await db.query(table);
    }
  }

  // Get input data for user
  static Future<List<double>> getInputData(int userId) async {
    List<Map<String, dynamic>> userResult =
        await DB.query('users', userId: userId);
    if (userResult.isEmpty) {
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }

    Map<String, dynamic> userData = userResult.first;
    DateTime birthDate = DateTime.parse(userData['birth_date']);
    double weight = userData['weight'];
    double height = userData['height'];
    int gender = userData['gender'] == 'male' ? 1 : 0;

    // Calculate age from birth date
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().isBefore(
        DateTime(DateTime.now().year, birthDate.month, birthDate.day))) {
      age--;
    }

    // Get workout data
    List<Map<String, dynamic>> results =
        await DB.query('entries', userId: userId);
    List<Entry> entries = results.map((item) => Entry.fromMap(item)).toList();

    if (entries.isEmpty) {
      return [
        age.toDouble(), // Age
        weight, // Weight (kg)
        height, // Height (cm)
        0.0, // Average speed (min/km)
        0.0, // Average distance (km)
        0.0, // Average duration (min)
        gender.toDouble(), // Gender (female: 0, male: 1)
        _getLevelNumeric(userData['level']).toDouble() // Level numerically
      ];
    }

    double totalSpeed = 0.0;
    double totalDistance = 0.0;
    double totalDuration = 0.0;

    for (var entry in entries) {
      totalSpeed += entry.speed;
      totalDistance += entry.distance;

      // Convert duration String to minutes
      var durationParts = entry.duration.split(':');
      if (durationParts.length == 2) {
        int minutes = int.parse(durationParts[0]);
        int seconds = int.parse(durationParts[1]);
        totalDuration += minutes + (seconds / 60.0); // Convert to minutes
      }
    }

    double avgSpeed = totalSpeed / entries.length;
    double avgDistance = totalDistance / entries.length;
    double avgDuration = totalDuration / entries.length;

    return [
      age.toDouble(), // Age
      weight, // Weight (kg)
      height, // Height (cm)
      avgSpeed, // Average speed (min/km)
      avgDistance, // Average distance (km)
      avgDuration, // Average duration (min)
      gender.toDouble(), // Gender (female: 0, male: 1)
      _getLevelNumeric(userData['level']).toDouble() // Level numerically
    ];
  }

  // Numeric encoding of level
  static int _getLevelNumeric(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 0;
      case 'intermediate':
        return 1;
      case 'advanced':
        return 2;
      default:
        return -1; // If the level is unknown
    }
  }
}
