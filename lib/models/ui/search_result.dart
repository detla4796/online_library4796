class SearchResult {
  final int bookId;
  final String bookTitle;
  final String authorName;
  final String status;
  final String? readerName;

  SearchResult({
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.status,
    this.readerName,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      bookId: map['id'],
      bookTitle: map['title'],
      authorName: map['full_name'],
      status: map['status'],
      readerName: map['reader_name'],
    );
  }
}