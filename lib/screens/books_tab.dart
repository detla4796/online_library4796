import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../widgets/issue_dialog.dart';
import '../widgets/return_dialog.dart';
import '../widgets/book_dialog.dart';
import '../models/database/book.dart';

class BooksTab extends StatelessWidget {
  final BookController controller;

  const BooksTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Добавить книгу'),
            onPressed: () => _showBookDialog(context, null),
          ),
        ),
        Expanded(
          child: controller.books.isEmpty
              ? Center(child: Text('Нет книг'))
              : ListView.builder(
                  itemCount: controller.books.length,
                  itemBuilder: (context, index) {
                    final book = controller.books[index];
                    final isOnShelf = book.status == 'on_shelf';

                    return ListTile(
                      title: Text(book.title),
                      subtitle: _buildSubtitle(book),
                      leading: Icon(
                        isOnShelf ? Icons.check_circle : Icons.person,
                        color: isOnShelf ? Colors.green : Colors.orange,
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('✏️ Редактировать'),
                            onTap: () => _showBookDialog(context, book),
                          ),
                          PopupMenuItem(
                            child: Text('🗑 Удалить'),
                            onTap: () => _showDeleteDialog(context, book),
                          ),
                          if (isOnShelf)
                            PopupMenuItem(
                              child: Text('📤 Выдать'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => IssueDialog(book: book),
                              ),
                            ),
                          if (!isOnShelf)
                            PopupMenuItem(
                              child: Text('📥 Вернуть'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => ReturnDialog(book: book),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBookDialog(BuildContext context, Book? book) {
    showDialog(
      context: context,
      builder: (context) => BookDialog(
        book: book,
        authors: controller.authors,
        controller: controller,
        onSave: (title, authorId) async {
          if (book == null) {
            await controller.addBook(title, authorId);
          } else {
            await controller.updateBook(book.id!, title, authorId);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить книгу?'),
        content: Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteBook(book.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(Book book) {
    final isOnShelf = book.status == 'on_shelf';
    final loanInfo = controller.loanInfoByBook[book.id];

    String text = isOnShelf ? 'На полке' : 'Выдана';

    if (!isOnShelf && loanInfo != null && loanInfo['isOverdue']) {
      text += ' (Просрочено на ${loanInfo['overdueDays']} дней)';
    }

    return Text(
      text,
      style: TextStyle(
        color: (!isOnShelf && loanInfo != null && loanInfo['isOverdue'])
            ? Colors.red
            : Colors.grey,
      ),
    );
  }
}