import 'package:flutter/material.dart';

class ReaderDialog extends StatefulWidget {
  final String? readerName;
  final Function(String name) onSave;

  const ReaderDialog({
    super.key,
    this.readerName,
    required this.onSave,
  });

  @override
  State<ReaderDialog> createState() => _ReaderDialogState();
}

class _ReaderDialogState extends State<ReaderDialog> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.readerName ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.readerName == null ? 'Добавить читателя' : 'Редактировать читателя'),
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
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              widget.onSave(nameController.text);
              Navigator.pop(context);
            }
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}