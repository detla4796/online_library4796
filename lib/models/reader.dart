class Reader {
  final int? id;
  final String name;

  Reader({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory Reader.fromMap(Map<String, dynamic> map) => Reader(
    id: map['id'],
    name: map['name'],
  );
}
