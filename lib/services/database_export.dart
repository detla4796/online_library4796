import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class DatabaseExport {
  static final _logger = Logger();
  static Future<String> exportToDownloads() async {
    try {
      final dbPath = await getDatabasesPath();
      final sourcePath = join(dbPath, 'library.db');
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        throw Exception('База данных не найдена');
      }

      final downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);
      
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final exportPath = join(downloadsPath, 'library_backup_$timestamp.db');
      
      await sourceFile.copy(exportPath);
      
      _logger.i('✅ База данных экспортирована в: $exportPath');
      _logger.i('📱 Используйте команду: adb pull $exportPath');
      
      return exportPath;
    } catch (e) {
      _logger.e('❌ Ошибка экспорта: $e');
      rethrow;
    }
  }
}