class Author {
  final int? id;
  final String fullName;

  Author({
    this.id,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'],
      fullName: map['full_name'],
    );
  }
}
