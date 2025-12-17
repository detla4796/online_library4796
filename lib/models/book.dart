class Book {
  final int? id;
  final String title;
  final int authorId;
  final String status;

  Book({
    this.id,
    required this.title,
    required this.authorId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author_id': authorId,
      'status': status,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authorId: map['author_id'],
      status: map['status'],
    );
  }
}
