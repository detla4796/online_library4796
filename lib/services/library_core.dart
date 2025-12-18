import '../database/library_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/loan.dart';
import '../models/reader.dart';

class LibraryCore {
  final LibraryDatabase _db = LibraryDatabase.instance;

  void _validateBookId(int bookId) {
    if (bookId <= 0) {
      throw ArgumentError('ID книги должен быть больше нуля');
    }
  }

  void _validateReaderId(int readerId) {
    if (readerId <= 0) {
      throw ArgumentError('ID читателя должен быть больше нуля');
    }
  }

  void _validateReaderName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Имя читателя не может быть пустым');
    }
    if (name.length > 100) {
      throw ArgumentError('Имя читателя не может быть больше 100 символов');
    }
  }

  Future<bool> isBookAvailable(int bookId) async {
    _validateBookId(bookId);
    
    final db = await _db.database;
    final result = await db.query(
      'books',
      where: 'id = ? AND status = ?',
      whereArgs: [bookId, 'on_shelf'],
    );

    return result.isNotEmpty;
  }

  Future<bool> loanBook({
    required int bookId,
    required int readerId,
  }) async {
    _validateBookId(bookId);
    _validateReaderId(readerId);
    
    final db = await _db.database;

    final available = await isBookAvailable(bookId);
    if (!available) {
      return false;
    }

    await db.insert(
      'loans',
      {
        'book_id': bookId,
        'reader_id': readerId,
        'loan_date': DateTime.now().toIso8601String(),
        'return_date': null,
      },
    );

    await db.update(
      'books',
      {'status': 'loaned'},
      where: 'id = ?',
      whereArgs: [bookId],
    );

    return true;
  }

  Future<void> returnBook(int bookId) async {
    _validateBookId(bookId);
    
    final db = await _db.database;

    await db.update(
      'loans',
      {
        'return_date': DateTime.now().toIso8601String(),
      },
      where: 'book_id = ? AND return_date IS NULL',
      whereArgs: [bookId],
    );

    await db.update(
      'books',
      {'status': 'on_shelf'},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await _db.database;
    final result = await db.query('books');
    return result.map((e) => Book.fromMap(e)).toList();
  }

  Future<int> addReader(String name) async {
    _validateReaderName(name);
    
    final db = await _db.database;
    return await db.insert(
      'readers',
      {
        'name': name.trim(),
      },
    );
  }

  Future<List<Reader>> getAllReaders() async {
    final db = await _db.database;
    final result = await db.query('readers');
    return result.map((e) => Reader.fromMap(e)).toList();
  }

  Future<Loan?> getActiveLoan(int bookId) async {
    _validateBookId(bookId);
    
    final db = await _db.database;
    final result = await db.query(
      'loans',
      where: 'book_id = ? AND return_date IS NULL',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Loan.fromMap(result.first);
  }

  Future<Reader?> getReaderById(int readerId) async {
    _validateReaderId(readerId);
    
    final db = await _db.database;
    final result = await db.query(
      'readers',
      where: 'id = ?',
      whereArgs: [readerId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Reader.fromMap(result.first);
  }

  Future<Book?> getBookById(int bookId) async {
    _validateBookId(bookId);
    
    final db = await _db.database;
    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Book.fromMap(result.first);
  }

  // TODO: smart search:
  // SELECT books.id, books.title, authors.full_name, readers.name
  // FROM books
  // JOIN authors ON books.author_id = authors.id
  // LEFT JOIN loans ON books.id = loans.book_id
  // LEFT JOIN readers ON loans.reader_id = readers.id
  // WHERE books.title LIKE ? OR authors.full_name LIKE ? OR readers.name LIKE ?

  // DEMO DATA
  Future<void> initDemoData() async {
    final db = await _db.database;

    final authorsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM authors')
    );

    if (authorsCount != 0) {
      return;
    }

    final authorId1 = await db.insert('authors', {
      'full_name': 'Фёдор Достоевский',
    });

    final authorId2 = await db.insert('authors', {
      'full_name': 'Лев Толстой',
    });

    await db.insert('books', {
      'title': 'Преступление и наказание',
      'author_id': authorId1,
      'status': 'on_shelf',
    });

    await db.insert('books', {
      'title': 'Война и мир',
      'author_id': authorId2,
      'status': 'on_shelf',
    });

    await db.insert('readers', {'name': 'Иван Иванов'});
    await db.insert('readers', {'name': 'Пётр Петров'});
  }
}