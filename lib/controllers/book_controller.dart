import 'package:flutter/material.dart';
import '../services/library_core.dart';
import '../models/database/book.dart';
import '../models/database/author.dart';
import '../models/database/reader.dart';
import '../models/ui/search_result.dart';
import '../services/validation.dart';

class BookController extends ChangeNotifier {
  final LibraryCore _core;
  BookController(this._core);
  
  List<Book> books = [];
  List<Reader> readers = [];
  List<Author> authors = [];
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
    Validation.bookId(bookId);
    Validation.readerId(readerId);
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
    Validation.bookId(bookId);
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
    Validation.searchQuery(query);
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

  Future<Map<String, dynamic>?> getLoanInfo(int bookId) async {
    return _core.getLoanInfo(bookId);
  }

  Future<void> loadAuthors() async {
    try {
      isLoading = true;
      notifyListeners();
      authors = await _core.getAllAuthors();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBook(String title, int authorId) async {
    try {
      await _core.addBook(title, authorId);
      await loadBooks();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(int bookId, String title, int authorId) async {
    Validation.bookId(bookId);
    try {
      await _core.updateBook(bookId, title, authorId);
      await loadBooks();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
    Validation.bookId(bookId);
    try {
      await _core.deleteBook(bookId);
      await loadBooks();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAuthor(String fullName) async {
    try {
      await _core.addAuthor(fullName);
      await loadAuthors();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReader(int readerId) async {
    Validation.readerId(readerId);
    try {
      await _core.deleteReader(readerId);
      await loadReaders();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> addReader(String name) async {
    try {
      Validation.readerName(name);
      await _core.addReader(name);
      await loadReaders();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deleteAuthor(int authorId) async {
    try {
      await _core.deleteAuthor(authorId);
      await loadAuthors();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAuthor(int authorId, String fullName) async {
    try {
      await _core.updateAuthor(authorId, fullName);
      await loadAuthors();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReader(int readerId, String name) async {
    try {
      await _core.updateReader(readerId, name);
      await loadReaders();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    searchResult = [];
    notifyListeners();
  }
}