import 'package:flutter/material.dart';
import '../services/library_core.dart';
import '../models/database/book.dart';
import '../models/database/reader.dart';
import '../models/ui/search_result.dart';

class BookController extends ChangeNotifier {
  final LibraryCore _core = LibraryCore();
  
  List<Book> books = [];
  List<Reader> readers = [];
  bool isLoading = false;
  String? errorMessage;
  List<SearchResult> searchResult = [];
  Map<int, Map<String, dynamic>> loanInfoByBook = {};

  Future<void> loadBooks() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      books = await _core.getAllBooks();
      await loadLoanInfo();
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

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      searchResult = [];
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      searchResult = await _core.smartSearch(query);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Ошибка поиска: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLoanInfo() async {
    loanInfoByBook.clear();

    for (final book in books) {
      if (book.status == 'loaned' && book.id != null) {
        final info = await _core.getLoanInfo(book.id!);
        if (info != null) {
          loanInfoByBook[book.id!] = info;
        }
      }
    }
    notifyListeners();
  }

  void clearSearch() {
    searchResult = [];
    notifyListeners();
  }
}