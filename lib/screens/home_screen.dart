import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/book_controller.dart';
import 'books_tab.dart';
import 'search_tab.dart';
import 'readers_tab.dart';
import 'authors_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<BookController>();
      controller.loadBooks();
      controller.loadAuthors();
      controller.loadReaders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Delta Shelf'),
        centerTitle: true,
      ),
      body: Consumer<BookController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text('Ошибка: ${controller.errorMessage}'));
          }

          return IndexedStack(
            index: _selectedIndex,
            children: [
              BooksTab(controller: controller),
              AuthorsTab(controller: controller),
              ReadersTab(controller: controller),
              SearchTab(controller: controller),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Книги',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_4),
              label: 'Авторы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Читатели',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Поиск',
            ),
          ],
        ),
      ),
    );
  }
}