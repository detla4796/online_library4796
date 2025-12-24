import '../database/library_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/database/book.dart';
import '../models/database/author.dart';
import '../models/database/loan.dart';
import '../models/database/reader.dart';
import '../models/ui/search_result.dart';
import '../services/validation.dart';

class LibraryCore {
  final LibraryDatabase _db;
  LibraryCore(this._db);
  static const int loanPeriodDays = 1; // *** set 1 day for test, default: 14 days ***
  
  Future<bool> isBookAvailable(int bookId) async {
    Validation.bookId(bookId);
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
    Validation.bookId(bookId);
    Validation.readerId(readerId);

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
    Validation.bookId(bookId);
    
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
    Validation.readerName(name);
    
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
    Validation.bookId(bookId);
    
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
    Validation.readerId(readerId);
    
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
    Validation.bookId(bookId);
    
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
    Validation.searchQuery(query);
    
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
    Validation.bookId(bookId);

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

    final loanDate = DateTime.parse(result.first['loan_date'] as String);

    return {
      'readerName': result.first['name'],
      'loanDate': loanDate.toIso8601String(),
      'isOverdue': isLoanOverdueByDate(loanDate),
      'overdueDays': getOverdueDaysByDate(loanDate),
    };
  }

  bool isLoanOverdueByDate(DateTime loanDate) {
    const loanPeriodDays = 1;
    final now = DateTime.now();
    return now.difference(loanDate).inDays > loanPeriodDays;
  }

  int getOverdueDaysByDate(DateTime loanDate) {
    const loanPeriodDays = 1;
    final days = DateTime.now().difference(loanDate).inDays;
    return days > loanPeriodDays ? days - loanPeriodDays : 0;
  }

  Future<int> addBook(String title, int authorId) async {
    final db = _db.db;
    return await db.insert('books', {
      'title': title,
      'author_id': authorId,
      'status': 'on_shelf',
    });
  }

  Future<void> updateBook(int bookId, String title, int authorId) async {
    Validation.bookId(bookId);
    final db = _db.db;
    await db.update(
      'books',
      {'title': title, 'author_id': authorId},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> deleteBook(int bookId) async {
    Validation.bookId(bookId);
    final db = _db.db;
    await db.delete('books', where: 'id = ?', whereArgs: [bookId]);
  }

  Future<List<Author>> getAllAuthors() async {
    final db = _db.db;
    final result = await db.rawQuery('SELECT DISTINCT id, full_name FROM authors ORDER BY full_name');
    return result.map((map) => Author.fromMap(map)).toList();
  }

  Future<int> addAuthor(String fullName) async {
    final name = fullName.trim();
    if (name.isEmpty) throw Exception('empty author name');
    final db = _db.db;
    final existing = await db.query(
      'authors',
      where: 'full_name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return await db.insert('authors', {'full_name': name});
  }

  Future<void> deleteAuthor(int authorId) async {
    final db = _db.db;
    await db.delete('authors', where: 'id = ?', whereArgs: [authorId]);
  }

  Future<void> updateAuthor(int authorId, String fullName) async {
    final db = _db.db;
    await db.update(
      'authors',
      {'full_name': fullName},
      where: 'id = ?',
      whereArgs: [authorId],
    );
  }

  Future<void> updateReader(int readerId, String name) async {
    Validation.readerName(name);
    final db = _db.db;
    await db.update(
      'readers',
      {'name': name},
      where: 'id = ?',
      whereArgs: [readerId],
    );
  }

  Future<void> deleteReader(int readerId) async {
    Validation.readerId(readerId);
    final db = _db.db;
    await db.delete('readers', where: 'id = ?', whereArgs: [readerId]);
  }
}