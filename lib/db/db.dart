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
      print('Creating table "entries"'); // Debug message
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

      print('Creating table "users"'); // Debug message
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
      try {
        String column = table == 'users'
            ? 'id'
            : 'user_id'; // Use 'id' for users table, 'user_id' for others
        List<Map<String, dynamic>> results = await db.query(
          table,
          where: '$column = ?',
          whereArgs: [userId], // Filter by correct column
        );
        print(
            'Query successful, retrieved ${results.length} records'); // Debug message
        return results;
      } catch (ex) {
        print(
            'Error during query for user_id: $userId, Error: $ex'); // Debug message
        return [];
      }
    } else {
      try {
        List<Map<String, dynamic>> results = await db.query(table);
        print(
            'Query successful, retrieved ${results.length} records'); // Debug message
        return results;
      } catch (ex) {
        print(
            'Error during query for table: $table, Error: $ex'); // Debug message
        return [];
      }
    }
  }

  // Normalizáló függvény (StandardScaler logika alapján)
  static double standardize(double value, double mean, double stdDev) {
    return (value - mean) / stdDev;
  }

  // Get input data for AI prediction
  static Future<List<double>> getInputData(int userId) async {
    print('Fetching input data for userId: $userId'); // Debug message
    List<Map<String, dynamic>> userResult =
        await DB.query('users', userId: userId);

    if (userResult.isEmpty) {
      print('No user data found for userId: $userId'); // Debug message
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }

    Map<String, dynamic> userData = userResult.first;
    DateTime birthDate = DateTime.parse(userData['birth_date']);
    double weight = userData['weight'];
    double height = userData['height'];
    int gender = userData['gender'] == 'Male' ? 1 : 0;

    // Calculate age
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().isBefore(
        DateTime(DateTime.now().year, birthDate.month, birthDate.day))) {
      age--;
    }

    print(
        'User data: Age=$age, Weight=$weight, Height=$height, Gender=$gender'); // Debug message

    // Fetch workout data
    List<Map<String, dynamic>> results =
        await DB.query('entries', userId: userId);
    List<Entry> entries = results.map((item) => Entry.fromMap(item)).toList();

    if (entries.isEmpty) {
      print('No workout data found for userId: $userId'); // Debug message
      return [
        standardize(age.toDouble(), meanAge, stdDevAge), // Standardized age
        standardize(
            weight, meanWeight, stdDevWeight), // Standardized weight (kg)
        standardize(
            height, meanHeight, stdDevHeight), // Standardized height (cm)
        gender.toDouble(), // Gender (female: 0, male: 1)
        _getLevelNumeric(userData['level'])
            .toDouble(), // Level encoded numerically
        0.0, // Average speed (min/km)
        0.0, // Average distance (km)
        0.0 // Average duration (seconds)
      ];
    }

    // Summing speed, distance, and duration for averaging
    double totalSpeed = 0.0;
    double totalDistance = 0.0;
    double totalDuration = 0.0;

    for (var entry in entries) {
      totalSpeed += entry.speed;
      totalDistance += entry.distance;

      // Convert duration from "HH:MM:SS" format to seconds
      var durationParts = entry.duration.split(':');
      if (durationParts.length == 3) {
        int hours = int.parse(durationParts[0]);
        int minutes = int.parse(durationParts[1]);
        int seconds = int.parse(durationParts[2]);
        totalDuration += (hours * 3600) + (minutes * 60) + seconds;
      } else if (durationParts.length == 2) {
        int minutes = int.parse(durationParts[0]);
        int seconds = int.parse(durationParts[1]);
        totalDuration += (minutes * 60) + seconds;
      } else {
        print('Invalid duration format for entry: $entry');
        totalDuration += 60.0; // Default to 1 minute if invalid
      }
    }

    double avgSpeed = totalSpeed / entries.length;
    double avgDistance = totalDistance / entries.length;
    double avgDuration = totalDuration / entries.length;

    print(
        'Averages calculated - Speed: $avgSpeed, Distance: $avgDistance, Duration: $avgDuration'); // Debug message

    return [
      standardize(age.toDouble(), meanAge, stdDevAge), // Standardized age
      standardize(weight, meanWeight, stdDevWeight), // Standardized weight (kg)
      standardize(height, meanHeight, stdDevHeight), // Standardized height (cm)
      gender.toDouble(), // Gender (female: 0, male: 1)
      _getLevelNumeric(userData['level'])
          .toDouble(), // Level encoded numerically
      standardize(avgSpeed, meanSpeed,
          stdDevSpeed), // Standardized average speed (min/km)
      standardize(avgDistance / 1000, meanDistance,
          stdDevDistance), // Standardized average distance (km)
      standardize(avgDuration, meanDuration,
          stdDevDuration) // Standardized average duration (seconds)
    ];
  }

  // Frissített statisztikai értékek a standardizáláshoz
  static const double meanAge = 39.11;
  static const double stdDevAge = 12.10;

  static const double meanWeight = 74.99;
  static const double stdDevWeight = 14.53;

  static const double meanHeight = 174.45;
  static const double stdDevHeight = 6.42;

  static const double meanSpeed = 6.58; // Min/km
  static const double stdDevSpeed = 1.20; // Min/km

  static const double meanDistance = 5.15; // Km
  static const double stdDevDistance = 1.77; // Km

  static const double meanDuration = 30.0 * 60; // 30 minutes in seconds
  static const double stdDevDuration = 60.0 * 60; // 1 hour in seconds

  // Helper method to convert user level to a numeric value
  static int _getLevelNumeric(String level) {
    switch (level) {
      case 'Beginner':
        return 1;
      case 'Intermediate':
        return 2;
      case 'Advanced':
        return 3;
      default:
        return 0; // Unknown level
    }
  }
}
