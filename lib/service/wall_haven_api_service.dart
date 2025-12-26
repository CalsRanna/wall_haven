import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/wallpaper_entity.dart';
import '../model/tag_entity.dart';
import '../model/search_result_entity.dart';
import '../util/rate_limiter.dart';
import '../util/logger_util.dart';

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
    final result = await _get('/w/$id');
    return WallpaperEntity.fromJson(result['data'] as Map<String, dynamic>);
  }

  /// Get tag information
  Future<TagEntity> getTag(int id) async {
    final result = await _get('/tag/$id');
    return TagEntity.fromJson(result['data'] as Map<String, dynamic>);
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
