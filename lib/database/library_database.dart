import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LibraryDatabase {
  static final LibraryDatabase instance = LibraryDatabase._init();
  static Database? _database;

  LibraryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('library.db');
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
    print('=== SQLite: создание базы данных ===');
    await db.execute('''
      CREATE TABLE authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL
      )
    ''');
    print('Таблица authors создана');
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES authors (id)
      )
    ''');
    print('Таблица books создана');
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        reader_name TEXT NOT NULL,
        loan_date TEXT NOT NULL,
        return_date TEXT,
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');
    print('Таблица loans создана');
    print('=== SQLite: база данных готова ===');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
