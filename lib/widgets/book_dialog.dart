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
  String? titleError;
  String? authorError;

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

  void _validateAndSave() {
    final title = titleController.text.trim();
    
    setState(() {
      titleError = title.isEmpty ? 'Введите название книги' : null;
      authorError = selectedAuthorId == null ? 'Выберите автора' : null;
    });

    if (titleError == null && authorError == null) {
      widget.onSave(title, selectedAuthorId!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final effectiveSelectedAuthorId = (selectedAuthorId != null && 
        items.any((it) => it.value == selectedAuthorId))
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
              decoration: InputDecoration(
                labelText: 'Название книги',
                errorText: titleError,
              ),
              onChanged: (_) {
                if (titleError != null) {
                  setState(() => titleError = null);
                }
              },
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            authorError = null;
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
                if (authorError != null)
                  Padding(
                    padding: EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      authorError!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
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
          onPressed: _validateAndSave,
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}