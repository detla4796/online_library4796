import 'package:flutter/material.dart';
import '../services/library_core.dart';
import '../models/book.dart';
import '../models/reader.dart';

class BookController extends ChangeNotifier {
  final LibraryCore _core = LibraryCore();
  
  List<Book> books = [];
  List<Reader> readers = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBooks() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      books = await _core.getAllBooks();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Ошибка загрузки: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> issueBook(int bookId, int readerId) async {
    try {
      final success = await _core.loanBook(
        bookId: bookId,
        readerId: readerId,
      );
      
      if (success) {
        await loadBooks();
        return true;
      }
      errorMessage = 'Книга недоступна';
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Ошибка: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnBook(int bookId) async {
    try {
      await _core.returnBook(bookId);
      await loadBooks();
      return true;
    } catch (e) {
      errorMessage = 'Ошибка возврата: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadReaders() async {
    try {
      readers = await _core.getAllReaders();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Ошибка загрузки читателей: $e';
      notifyListeners();
    }
  }
}