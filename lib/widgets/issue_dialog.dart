import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/book_controller.dart';
import '../models/book.dart';
import '../models/reader.dart';

class IssueDialog extends StatefulWidget {
  final Book book;

  const IssueDialog({
    super.key,
    required this.book,
  });

  @override
  State<IssueDialog> createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog> {
  Reader? selectedReader;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookController>().loadReaders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выдать книгу'),
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
            Text('Выберите читателя:'),
            SizedBox(height: 8),
            Consumer<BookController>(
              builder: (context, controller, _) {
                if (controller.readers.isEmpty) {
                  return Text('Нет читателей в системе');
                }

                return DropdownButton<Reader>(
                  isExpanded: true,
                  value: selectedReader,
                  hint: Text('Выберите читателя'),
                  items: controller.readers.map((reader) {
                    return DropdownMenuItem<Reader>(
                      value: reader,
                      child: Text(reader.name),
                    );
                  }).toList(),
                  onChanged: (reader) {
                    setState(() {
                      selectedReader = reader;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Дата выдачи: ${DateTime.now().toLocal().toString().split('.')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: selectedReader == null || isLoading
              ? null
              : () => _issueBook(context),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Выдать'),
        ),
      ],
    );
  }

  Future<void> _issueBook(BuildContext context) async {
    setState(() => isLoading = true);

    final controller = context.read<BookController>();
    final success = await controller.issueBook(
      widget.book.id!,
      selectedReader!.id!,
    );

    setState(() => isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Книга выдана успешно!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage ?? 'Ошибка выдачи')),
        );
      }
    }
  }
}