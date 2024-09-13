import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

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
          date STRING, 
          duration STRING, 
          speed REAL, 
          distance REAL
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
          weight REAL
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

  // Query data from a table
  static Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await getDatabase();
    print('Querying table: $table'); // Debug message
    return await db.query(table);
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
