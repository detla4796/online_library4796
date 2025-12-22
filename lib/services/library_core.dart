import '../database/library_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/database/book.dart';
import '../models/database/author.dart';
import '../models/database/loan.dart';
import '../models/database/reader.dart';
import '../models/ui/search_result.dart';

class LibraryCore {
  final LibraryDatabase _db = LibraryDatabase.instance;
  static const int loanPeriodDays = 14;

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
    final db = _db.db;
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

    final db = _db.db;

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
    
    final db = _db.db;

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
    final db = _db.db;
    final result = await db.query('books');
    return result.map((e) => Book.fromMap(e)).toList();
  }

  Future<int> addReader(String name) async {
    _validateReaderName(name);
    
    final db = _db.db;
    return await db.insert(
      'readers',
      {
        'name': name.trim(),
      },
    );
  }

  Future<List<Reader>> getAllReaders() async {
    final db = _db.db;
    final result = await db.query('readers');
    return result.map((e) => Reader.fromMap(e)).toList();
  }

  Future<Loan?> getActiveLoan(int bookId) async {
    _validateBookId(bookId);
    
    final db = _db.db;
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
    
    final db = _db.db;
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
    
    final db = _db.db;
    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isEmpty) return null;
      return Book.fromMap(result.first);
    }

    Future<List<SearchResult>> smartSearch(String query) async {
    _validateSearchQuery(query);
    
    final db = _db.db;
    final searchPattern = '%${query.trim()}%';
    
    final result = await db.rawQuery('''
      SELECT 
        books.id,
        books.title,
        authors.full_name,
        books.status,
        readers.name as reader_name
      FROM books
      JOIN authors ON books.author_id = authors.id
      LEFT JOIN loans ON books.id = loans.book_id AND loans.return_date IS NULL
      LEFT JOIN readers ON loans.reader_id = readers.id
      WHERE books.title LIKE ? OR authors.full_name LIKE ? OR readers.name LIKE ?
      ORDER BY books.title
    ''', [searchPattern, searchPattern, searchPattern]);

    return result.map((e) => SearchResult.fromMap(e)).toList();
  }

  void _validateSearchQuery(String query) {
    if (query.trim().isEmpty) {
      throw ArgumentError('Поисковый запрос не может быть пустым');
    }
    if (query.length > 200) {
      throw ArgumentError('Поисковый запрос слишком длинный');
    }
  }

  bool isLoanOverdue(Loan loan) {
    final loanDate = DateTime.parse(loan.loanDate);
    final now = DateTime.now();
    return now.difference(loanDate).inDays > loanPeriodDays;
  }

  int getOverdueDays(Loan loan) {
    final loanDate = DateTime.parse(loan.loanDate);
    final now = DateTime.now();
    final overdueDays = now.difference(loanDate).inDays - loanPeriodDays;
    return overdueDays > 0 ? overdueDays : 0;
  }

  DateTime now() => DateTime.now(); // for testing purposes

  Future<Map<String, dynamic>?> getLoanInfo(int bookId) async {
    _validateBookId(bookId);

    final db = _db.db;

    final result = await db.rawQuery('''
      SELECT 
        loans.loan_date,
        readers.name
      FROM loans
      JOIN readers ON loans.reader_id = readers.id
      WHERE loans.book_id = ?
        AND loans.return_date IS NULL
      LIMIT 1
    ''', [bookId]);

    if (result.isEmpty) return null;

    final loan = Loan.fromMap({
      'loan_date': result.first['loan_date'],
      'book_id': bookId,
      'reader_id': 0,
    });

    return {
      'readerName': result.first['name'],
      'loanDate': loan.loanDate,
      'isOverdue': isLoanOverdue(loan),
      'overdueDays': getOverdueDays(loan),
    };
  }


  // DEMO DATA
  Future<void> initDemoData({bool force = false}) async { // add force parameter for re-initialization if its needed
    final db = _db.db;

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