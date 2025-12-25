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
  String? errorMessage;

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

  void _validateAndSave() {
    final text = nameController.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        errorMessage = 'Введите имя читателя';
      });
      return;
    }

    widget.onSave(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.readerName == null 
          ? 'Добавить читателя' 
          : 'Редактировать читателя'),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: 'Имя читателя',
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
          onPressed: _validateAndSave,
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}