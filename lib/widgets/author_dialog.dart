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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Добавить автора'),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: 'Полное имя автора'),
        enabled: !isLoading,
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (nameController.text.isNotEmpty) {
                    setState(() => isLoading = true);
                    await widget.onSave(nameController.text);
                    if (mounted) Navigator.pop(context);
                  }
                },
          child: Text('Добавить'),
        ),
      ],
    );
  }
}