import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'logger_util.dart';

/// API Response Cache Utility
/// Caches API responses to local files with 7-day expiration
class ApiCacheUtil {
  static final ApiCacheUtil instance = ApiCacheUtil._();
  static const _cacheDuration = Duration(days: 7);

  late Directory _cacheDir;

  ApiCacheUtil._();

  /// Initialize cache directory
  Future<void> ensureInitialized() async {
    final appDir = await getApplicationSupportDirectory();
    _cacheDir = Directory('${appDir.path}/api_cache');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
    LoggerUtil.instance.i('API cache initialized at: ${_cacheDir.path}');
  }

  /// Convert URL to unique file name using SHA256
  String _urlToFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cached response for URL
  /// Returns null if cache doesn't exist or is expired
  Future<Map<String, dynamic>?> get(String url) async {
    try {
      final fileName = _urlToFileName(url);
      final file = File('${_cacheDir.path}/$fileName.json');

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final cached = jsonDecode(content) as Map<String, dynamic>;

      // Check expiration
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        cached['cachedAt'] as int,
      );
      final now = DateTime.now();

      if (now.difference(cachedAt) > _cacheDuration) {
        // Cache expired, delete file
        await file.delete();
        LoggerUtil.instance.d('Cache expired for: $url');
        return null;
      }

      LoggerUtil.instance.d('Cache hit for: $url');
      return cached['data'] as Map<String, dynamic>;
    } catch (e) {
      LoggerUtil.instance.e('Failed to read cache', e);
      return null;
    }
  }

  /// Save response to cache
  Future<void> set(String url, Map<String, dynamic> data) async {
    try {
      final fileName = _urlToFileName(url);
      final file = File('${_cacheDir.path}/$fileName.json');

      final cacheData = {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };

      await file.writeAsString(jsonEncode(cacheData));
      LoggerUtil.instance.d('Cache saved for: $url');
    } catch (e) {
      LoggerUtil.instance.e('Failed to write cache', e);
    }
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    try {
      if (!await _cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in _cacheDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      LoggerUtil.instance.e('Failed to get cache size', e);
      return 0;
    }
  }

  /// Get formatted cache size string
  Future<String> getCacheSizeFormatted() async {
    final size = await getCacheSize();
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get list of cache files with metadata
  Future<List<CacheFileInfo>> getCacheFiles() async {
    try {
      if (!await _cacheDir.exists()) {
        return [];
      }

      final files = <CacheFileInfo>[];
      await for (final entity in _cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final stat = await entity.stat();
          final content = await entity.readAsString();
          final cached = jsonDecode(content) as Map<String, dynamic>;
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            cached['cachedAt'] as int,
          );

          files.add(CacheFileInfo(
            fileName: entity.uri.pathSegments.last,
            size: stat.size,
            cachedAt: cachedAt,
            filePath: entity.path,
          ));
        }
      }

      // Sort by cached time (newest first)
      files.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
      return files;
    } catch (e) {
      LoggerUtil.instance.e('Failed to get cache files', e);
      return [];
    }
  }

  /// Clear all cache files
  Future<void> clearCache() async {
    try {
      if (!await _cacheDir.exists()) {
        return;
      }

      await for (final entity in _cacheDir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
      LoggerUtil.instance.i('Cache cleared');
    } catch (e) {
      LoggerUtil.instance.e('Failed to clear cache', e);
    }
  }
}

/// Cache file information
class CacheFileInfo {
  final String fileName;
  final int size;
  final DateTime cachedAt;
  final String filePath;

  CacheFileInfo({
    required this.fileName,
    required this.size,
    required this.cachedAt,
    required this.filePath,
  });

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
