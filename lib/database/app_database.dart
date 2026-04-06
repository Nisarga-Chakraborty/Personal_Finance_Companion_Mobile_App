import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  // Single instance — call this everywhere you need the db
  static Future<Database> getInstance() async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_app.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the transactions table
  // it has 6 columns: id, amount, type, category, date, and note
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id        TEXT PRIMARY KEY,
        amount    REAL NOT NULL,
        type      TEXT NOT NULL,
        category  TEXT NOT NULL,
        date      TEXT NOT NULL,
        note      TEXT
      )
    ''');

    // Create the budget table
    await db.execute('''
      CREATE TABLE budget (
        id        TEXT PRIMARY KEY,
        month     INTEGER NOT NULL,
        year      INTEGER NOT NULL,
        amount    REAL NOT NULL,
        UNIQUE(month, year)
      )
    ''');

    // Create the users table
    await db.execute('''
      CREATE TABLE users (
        id              TEXT PRIMARY KEY,
        name            TEXT NOT NULL,
        age             INTEGER NOT NULL,
        gender          TEXT NOT NULL,
        photoPath       TEXT,
        monthlyBudget   REAL NOT NULL DEFAULT 10000,
        currency        TEXT NOT NULL DEFAULT '₹'
      )
    ''');
  }
}
