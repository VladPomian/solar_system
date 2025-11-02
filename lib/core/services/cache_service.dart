import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Future<Directory> get _tempDir async => await getTemporaryDirectory();
  Future<Directory> get _appCacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/cache');
  }

  /// Возвращает размер кэша в байтах
  Future<int> getCacheSize() async {
    try {
      int total = 0;
      total += await _dirSize(await _tempDir);
      total += await _dirSize(await _appCacheDir);
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _dirSize(Directory dir) async {
    if (!dir.existsSync()) return 0;
    int size = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  /// Очистка кэша
  Future<void> clearCache() async {
    try {
      final tempDir = await _tempDir;
      final cacheDir = await _appCacheDir;

      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
    } catch (e) {}
  }

  /// Форматирование
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ГБ';
  }
}