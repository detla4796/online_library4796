import 'package:flutter/material.dart';

class AuthorDialog extends StatefulWidget {
  final Function(String fullName) onSave;

  const AuthorDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AuthorDialog> createState() => _AuthorDialogState();
}

class _AuthorDialogState extends State<AuthorDialog> {
  late TextEditingController nameController;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    final text = nameController.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        errorMessage = 'Введите имя автора';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await widget.onSave(text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Добавить автора'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Полное имя автора',
              errorText: errorMessage,
            ),
            enabled: !isLoading,
            onChanged: (_) {
              if (errorMessage != null) {
                setState(() => errorMessage = null);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _validateAndSave,
          child: Text('Добавить'),
        ),
      ],
    );
  }
}