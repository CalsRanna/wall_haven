import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/wallpaper_entity.dart';
import '../model/tag_entity.dart';
import '../model/search_result_entity.dart';
import '../model/collection_entity.dart';
import '../util/rate_limiter.dart';
import '../util/logger_util.dart';
import '../util/api_cache_util.dart';

/// API Exception
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

/// Rate Limit Exception
class RateLimitException implements Exception {
  @override
  String toString() => 'RateLimitException: API rate limit exceeded (45/min)';
}

/// WallHaven API Service
class WallHavenApiService {
  static const baseUrl = 'https://wallhaven.cc/api/v1';

  final _rateLimiter = RateLimiter(maxRequests: 45);
  final _client = http.Client();
  String? _apiKey;

  void setApiKey(String? key) {
    _apiKey = key;
    LoggerUtil.instance.i('API Key ${key != null ? "set" : "cleared"}');
  }

  String? get apiKey => _apiKey;

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
  }) async {
    await _rateLimiter.acquire();

    final queryParams = <String, String>{
      ...?params,
      if (_apiKey != null && _apiKey!.isNotEmpty) 'apikey': _apiKey!,
    };

    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    LoggerUtil.instance.d('GET $uri');

    final response = await _client.get(uri);

    if (response.statusCode == 429) {
      throw RateLimitException();
    }

    if (response.statusCode == 401) {
      throw ApiException(401, 'Unauthorized: Invalid API key');
    }

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Search wallpapers
  Future<SearchResultEntity> search({
    String? query,
    String categories = '111',
    String purity = '100',
    String sorting = 'date_added',
    String order = 'desc',
    String? topRange,
    String? atleast,
    String? resolutions,
    String? ratios,
    String? colors,
    String? seed,
    int page = 1,
  }) async {
    final params = <String, String>{
      'categories': categories,
      'purity': purity,
      'sorting': sorting,
      'order': order,
      'page': page.toString(),
      if (query != null && query.isNotEmpty) 'q': query,
      if (topRange != null) 'topRange': topRange,
      if (atleast != null) 'atleast': atleast,
      if (resolutions != null) 'resolutions': resolutions,
      if (ratios != null) 'ratios': ratios,
      if (colors != null) 'colors': colors,
      if (seed != null) 'seed': seed,
    };

    final result = await _get('/search', params: params);
    return SearchResultEntity.fromJson(result);
  }

  /// Get wallpaper details
  Future<WallpaperEntity> getWallpaper(String id) async {
    final url = '$baseUrl/w/$id';

    // 1. Try to get from cache
    final cached = await ApiCacheUtil.instance.get(url);
    if (cached != null) {
      LoggerUtil.instance.i('Wallpaper $id loaded from cache');
      return WallpaperEntity.fromJson(cached['data'] as Map<String, dynamic>);
    }

    // 2. Fetch from network
    final result = await _get('/w/$id');

    // 3. Save to cache
    await ApiCacheUtil.instance.set(url, result);

    // 4. Return parsed entity
    return WallpaperEntity.fromJson(result['data'] as Map<String, dynamic>);
  }

  /// Get tag information
  Future<TagEntity> getTag(int id) async {
    final result = await _get('/tag/$id');
    return TagEntity.fromJson(result['data'] as Map<String, dynamic>);
  }

  /// Get current user's collections (requires API key)
  Future<List<CollectionEntity>> getMyCollections() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw ApiException(401, 'API key required for collections');
    }

    final result = await _get('/collections');
    final data = result['data'] as List<dynamic>;
    return data
        .map((e) => CollectionEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a user's public collections
  Future<List<CollectionEntity>> getUserCollections(String username) async {
    final result = await _get('/collections/$username');
    final data = result['data'] as List<dynamic>;
    return data
        .map((e) => CollectionEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get wallpapers in a collection
  Future<SearchResultEntity> getCollectionWallpapers({
    required String username,
    required int collectionId,
    int page = 1,
  }) async {
    final result = await _get(
      '/collections/$username/$collectionId',
      params: {'page': page.toString()},
    );
    return SearchResultEntity.fromJson(result);
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
