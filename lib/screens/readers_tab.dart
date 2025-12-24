import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';
import '../widgets/reader_dialog.dart';
import '../models/database/reader.dart';

class ReadersTab extends StatelessWidget {
  final BookController controller;

  const ReadersTab({
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
            label: Text('Добавить читателя'),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ReaderDialog(
                onSave: (name) async {
                  await controller.addReader(name);
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: controller.readers.isEmpty
              ? Center(child: Text('Нет читателей'))
              : ListView.builder(
                  itemCount: controller.readers.length,
                  itemBuilder: (context, index) {
                    final reader = controller.readers[index];

                    return ListTile(
                      title: Text(reader.name),
                      leading: Icon(Icons.person),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('✏️ Редактировать'),
                            onTap: () => _showEditDialog(context, reader),
                          ),
                          PopupMenuItem(
                            child: Text('🗑 Удалить'),
                            onTap: () => _showDeleteDialog(context, reader.id!),
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

  void _showDeleteDialog(BuildContext context, int readerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить читателя?'),
        content: Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteReader(readerId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Reader reader) {
    final nameController = TextEditingController(text: reader.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать читателя'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Имя читателя'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateReader(reader.id!, nameController.text);
              Navigator.pop(context);
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}