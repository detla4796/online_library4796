import 'package:flutter/material.dart';
import 'database/library_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibraryDatabase.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Онлайн-библиотека'),
        ),
      ),
    );
  }
}