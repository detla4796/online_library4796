class Validation {
  static void bookId(int id) {
    if (id <= 0) {
      throw ArgumentError('Invalid book id');
    }
  }

  static void readerId(int id) {
    if (id <= 0) {
      throw ArgumentError('Invalid reader id');
    }
  }

  static void readerName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Reader name is empty');
    }
    if (name.length > 100) {
      throw ArgumentError('Reader name too long');
    }
  }

  static void searchQuery(String query) {
    if (query.trim().isEmpty) {
      throw ArgumentError('Empty search query');
    }
  }
}
