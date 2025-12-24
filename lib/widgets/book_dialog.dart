import 'package:flutter/material.dart';
import '../models/database/book.dart';
import '../models/database/author.dart';
import '../controllers/book_controller.dart';
import 'author_dialog.dart';

class BookDialog extends StatefulWidget {
  final Book? book;
  final List<Author> authors;
  final BookController controller;
  final Function(String title, int authorId) onSave;

  const BookDialog({
    super.key,
    this.book,
    required this.authors,
    required this.controller,
    required this.onSave,
  });

  @override
  State<BookDialog> createState() => _BookDialogState();
}

class _BookDialogState extends State<BookDialog> {
  late TextEditingController titleController;
  int? selectedAuthorId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book?.title ?? '');
    selectedAuthorId = widget.book?.authorId;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _showAddAuthorDialog() {
    showDialog(
      context: context,
      builder: (context) => AuthorDialog(
        onSave: (fullName) async {
          await widget.controller.addAuthor(fullName);
          if (mounted) {
            await widget.controller.loadAuthors();
            setState(() {
              if (widget.controller.authors.isNotEmpty) {
                selectedAuthorId = widget.controller.authors.last.id;
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // dedupe authors by id using controller's current list (most up-to-date)
    final Map<int, Author> byId = {};
    for (final a in widget.controller.authors) {
      if (a.id != null) byId[a.id!] = a;
    }
    final items = byId.values.map((author) {
      return DropdownMenuItem<int>(
        value: author.id,
        child: Text(author.fullName),
      );
    }).toList();

    // don't mutate state in build; compute effective selected value
    final effectiveSelectedAuthorId =
        (selectedAuthorId != null && items.any((it) => it.value == selectedAuthorId))
            ? selectedAuthorId
            : null;

    return AlertDialog(
      title: Text(widget.book == null ? 'Добавить книгу' : 'Редактировать книгу'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Название книги'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: effectiveSelectedAuthorId,
                    hint: Text('Выберите автора'),
                    isExpanded: true,
                    items: items,
                    onChanged: (value) {
                      setState(() {
                        selectedAuthorId = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _showAddAuthorDialog,
                ),
              ],
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
          onPressed: () {
            if (titleController.text.isNotEmpty && selectedAuthorId != null) {
              widget.onSave(titleController.text, selectedAuthorId!);
              Navigator.pop(context);
            }
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}

