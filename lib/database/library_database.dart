import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LibraryDatabase {
  static final LibraryDatabase instance = LibraryDatabase._init();
  static Database? _database;

  LibraryDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      print('SQLite: база данных уже открыта');
      return _database!;
    }

    print('SQLite: открытие базы данных');
    _database = await _initDB('library.db');
    return _database!;
  }

  Database get db {
    if (_database == null) {
      throw Exception('Database is not initialized. Call database getter first.');
    }
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print('SQLite: база данных создаётся');
    await db.execute('''
      CREATE TABLE authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES authors (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE readers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        reader_id INTEGER NOT NULL,
        loan_date TEXT NOT NULL,
        return_date TEXT,
        FOREIGN KEY (book_id) REFERENCES books (id),
        FOREIGN KEY (reader_id) REFERENCES readers (id)
      )
    ''');
    print('SQLite: база данных успешно создана');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
