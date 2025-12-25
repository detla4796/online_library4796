import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/library_database.dart';

class DatabaseExport {
  // Экспорт в Downloads (для adb pull)
  static Future<String> exportToDownloads() async {
    try {
      // Получаем путь к базе данных
      final dbPath = await getDatabasesPath();
      final sourcePath = join(dbPath, 'library.db');
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        throw Exception('База данных не найдена');
      }

      // Путь к папке Downloads в эмуляторе
      // /storage/emulated/0/Download
      final downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);
      
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final exportPath = join(downloadsPath, 'library_backup_$timestamp.db');
      
      // Копируем БД в Downloads
      await sourceFile.copy(exportPath);
      
      print('✅ База данных экспортирована в: $exportPath');
      print('📱 Используйте команду: adb pull $exportPath');
      
      return exportPath;
    } catch (e) {
      print('❌ Ошибка экспорта: $e');
      rethrow;
    }
  }
}