import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/book_controller.dart';
import '../models/book.dart';
import '../services/library_core.dart';

class ReturnDialog extends StatefulWidget {
  final Book book;

  const ReturnDialog({
    super.key,
    required this.book,
  });

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  bool isLoading = false;
  String? readerName;
  String? loanDate;

  @override
  void initState() {
    super.initState();
    _loadLoanInfo();
  }

  Future<void> _loadLoanInfo() async {
    final core = LibraryCore();
    final loan = await core.getActiveLoan(widget.book.id!);

    if (loan != null) {
      final reader = await core.getReaderById(loan.readerId);
      setState(() {
        readerName = reader?.name ?? 'Неизвестный читатель';
        loanDate = loan.loanDate.split('T')[0]; // only date part
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Вернуть книгу'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Книга: ${widget.book.title}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (readerName != null) ...[
              Text('Читатель: $readerName'),
              SizedBox(height: 8),
              Text('Дата выдачи: $loanDate'),
              SizedBox(height: 8),
              Text(
                'Дата возврата: ${DateTime.now().toLocal().toString().split('.')[0]}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ] else
              CircularProgressIndicator(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: readerName == null || isLoading
              ? null
              : () => _returnBook(context),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Вернуть'),
        ),
      ],
    );
  }

  Future<void> _returnBook(BuildContext context) async {
    setState(() => isLoading = true);

    final controller = context.read<BookController>();
    final success = await controller.returnBook(widget.book.id!);

    setState(() => isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Книга возвращена успешно!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage ?? 'Ошибка возврата')),
        );
      }
    }
  }
}