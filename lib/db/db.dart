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
          user_id INTEGER,  -- Add this line
          date STRING, 
          duration STRING, 
          speed REAL, 
          distance REAL,
          speed_per_km TEXT,
          elevation_gain REAL,
          FOREIGN KEY(user_id) REFERENCES users(id)  -- Add this line
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

  // Adatok beszúrása egy táblába
  static Future<int> insert(String table, Map<String, dynamic> item) async {
    final db = await getDatabase();

    // Debug üzenet: a beszúrandó elem megjelenítése
    print('Inserting into table: $table, Item: $item');

    int result = await db.insert(table, item,
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Debug üzenet: a beszúrás eredményének ellenőrzése
    print('Insert result: $result');

    return result;
  }

// Adatok lekérdezése egy táblából
  static Future<List<Map<String, dynamic>>> query(String table,
      {int? userId}) async {
    final db = await getDatabase();

    // Debug üzenet: a lekérdezés és szűrő megjelenítése
    print('Querying table: $table for user_id: $userId');

    if (userId != null) {
      return await db.query(
        table,
        where: 'user_id = ?',
        whereArgs: [userId], // Szűrés user_id alapján
      );
    } else {
      return await db.query(table);
    }
  }
}
