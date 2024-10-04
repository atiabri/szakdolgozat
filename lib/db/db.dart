import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class DB {
  static Database? _db;
  static int get _version => 2; // Verziót frissítettük 2-re

  // Initialize the database
  static Future<void> init() async {
    try {
      String _path = await getDatabasesPath();
      String _dbpath = p.join(_path, 'database.db');
      print('Opening database at path: $_dbpath'); // Debug message
      _db = await openDatabase(_dbpath,
          version: _version, onCreate: onCreate, onUpgrade: onUpgrade);
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
          elevation_gain REAL,
          speed_per_km TEXT,
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
          level TEXT  -- Új mező a szinthez
        )
      ''');
      print('Table "users" created'); // Debug message
    } catch (ex) {
      print('Error creating tables: $ex'); // Debug message
    }
  }

  // Upgrade database for version changes
  static FutureOr<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN level TEXT DEFAULT "Beginner"');
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

  // Query data from a table
  static Future<List<Map<String, dynamic>>> query(String table,
      {int? userId}) async {
    final db = await getDatabase();
    print('Querying table: $table'); // Debug message
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

  // Insert data into a table
  static Future<int> insert(String table, Map<String, dynamic> item) async {
    final db = await getDatabase();
    print('Inserting into table: $table'); // Debug message
    print('Item: $item'); // Debug message
    return await db.insert(table, item,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
