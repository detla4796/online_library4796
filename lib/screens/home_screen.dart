import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/book_controller.dart';
import '../widgets/issue_dialog.dart';
import '../widgets/return_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detla Shelf'),
      ),
      body: Consumer<BookController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text('Ошибка: ${controller.errorMessage}'));
          }

          if (controller.books.isEmpty) {
            return Center(child: Text('Книг пока нет'));
          }

          return ListView.builder(
            itemCount: controller.books.length,
            itemBuilder: (context, index) {
              final book = controller.books[index];
              final isOnShelf = book.status == 'on_shelf';
              final loanInfo = controller.loanInfoByBook[book.id];
              final isOverdue = loanInfo?['isOverdue'] == true;
              final overdueDays = loanInfo?['overdueDays'];

              return ListTile(
                onTap: () {
                  if (isOnShelf) {
                    showDialog(
                      context: context,
                      builder: (_) => IssueDialog(book: book),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => ReturnDialog(book: book),
                    );
                  }
                },
                title: Text(book.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnShelf ? 'На полке' : 'Выдана',
                      style: TextStyle(
                        color: isOnShelf ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isOverdue)
                      Text(
                        'Просрочено на $overdueDays дней',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                leading: Icon(
                  isOverdue
                      ? Icons.warning
                      : isOnShelf
                          ? Icons.book
                          : Icons.bookmark,
                  color: isOverdue
                      ? Colors.red
                      : isOnShelf
                          ? Colors.green
                          : Colors.orange,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              );
            },
          );
        },
      ),
    );
  }
}