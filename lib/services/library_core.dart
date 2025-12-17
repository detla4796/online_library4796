import '../database/library_database.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/loan.dart';

class LibraryCore {
  final LibraryDatabase _db = LibraryDatabase.instance;

  Future<bool> isBookAvailable(int bookId) async {
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
    required String readerName,
  }) async {
    final db = await _db.database;

    final available = await isBookAvailable(bookId);
    if (!available) {
      return false;
    }

      await db.insert(
        'loans',
        {
          'book_id': bookId,
          'reader_name': readerName,
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
}