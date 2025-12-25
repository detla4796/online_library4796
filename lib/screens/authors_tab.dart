import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../widgets/author_dialog.dart';
import '../models/database/author.dart';

class AuthorsTab extends StatelessWidget {
  final BookController controller;

  const AuthorsTab({
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
            label: Text('Добавить автора'),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AuthorDialog(
                onSave: (fullName) async {
                  await controller.addAuthor(fullName);
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: controller.authors.isEmpty
              ? Center(child: Text('Нет авторов'))
              : ListView.builder(
                  itemCount: controller.authors.length,
                  itemBuilder: (context, index) {
                    final author = controller.authors[index];

                    return ListTile(
                      title: Text(author.fullName),
                      leading: Icon(Icons.person_4),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('✏️ Редактировать'),
                            onTap: () => _showEditDialog(context, author),
                          ),
                          PopupMenuItem(
                            child: Text('🗑 Удалить'),
                            onTap: () => _showDeleteDialog(context, author.id!),
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

  void _showEditDialog(BuildContext context, Author author) {
    final nameController = TextEditingController(text: author.fullName);
    String? errorMessage;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Редактировать автора'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Полное имя автора',
              errorText: errorMessage,
            ),
            onChanged: (_) {
              if (errorMessage != null) {
                setState(() => errorMessage = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = nameController.text.trim();
                if (text.isEmpty) {
                  setState(() => errorMessage = 'Введите имя автора');
                  return;
                }
                await controller.updateAuthor(author.id!, text);
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int authorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить автора?'),
        content: Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteAuthor(authorId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}