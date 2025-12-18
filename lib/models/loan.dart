class Loan {
  final int? id;
  final int bookId;
  final int readerId;
  final String loanDate;
  final String? returnDate;

  Loan({
    this.id,
    required this.bookId,
    required this.readerId,
    required this.loanDate,
    this.returnDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'reader_id': readerId,
      'loan_date': loanDate,
      'return_date': returnDate,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      bookId: map['book_id'],
      readerId: map['reader_id'],
      loanDate: map['loan_date'],
      returnDate: map['return_date'],
    );
  }
}
