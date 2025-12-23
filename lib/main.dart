import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/library_database.dart';
import 'screens/home_screen.dart';
import 'services/library_core.dart';
import 'controllers/book_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = LibraryDatabase.instance;
  await db.database;

  final core = LibraryCore();
  await core.initDemoData();

  runApp(
    MyApp(core: core),
  );
}

class MyApp extends StatelessWidget {
  final LibraryCore core;

  const MyApp({super.key, required this.core});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookController(core)..loadBooks(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
