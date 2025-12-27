// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;
import 'package:wall_haven/page/detail/detail_page.dart' as _i2;
import 'package:wall_haven/page/discover/discover_page.dart' as _i3;
import 'package:wall_haven/page/favorite/favorite_page.dart' as _i4;
import 'package:wall_haven/page/home_page.dart' as _i5;
import 'package:wall_haven/page/search/search_page.dart' as _i6;
import 'package:wall_haven/page/setting/cache_files_page.dart' as _i1;
import 'package:wall_haven/page/setting/setting_page.dart' as _i7;

/// generated route for
/// [_i1.CacheFilesPage]
class CacheFilesRoute extends _i8.PageRouteInfo<void> {
  const CacheFilesRoute({List<_i8.PageRouteInfo>? children})
    : super(CacheFilesRoute.name, initialChildren: children);

  static const String name = 'CacheFilesRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.CacheFilesPage();
    },
  );
}

/// generated route for
/// [_i2.DetailPage]
class DetailRoute extends _i8.PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    _i9.Key? key,
    required String wallpaperId,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(key: key, wallpaperId: wallpaperId),
         rawPathParams: {'id': wallpaperId},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(wallpaperId: pathParams.getString('id')),
      );
      return _i2.DetailPage(key: args.key, wallpaperId: args.wallpaperId);
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({this.key, required this.wallpaperId});

  final _i9.Key? key;

  final String wallpaperId;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, wallpaperId: $wallpaperId}';
  }
}

/// generated route for
/// [_i3.DiscoverPage]
class DiscoverRoute extends _i8.PageRouteInfo<void> {
  const DiscoverRoute({List<_i8.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.DiscoverPage();
    },
  );
}

/// generated route for
/// [_i4.FavoritePage]
class FavoriteRoute extends _i8.PageRouteInfo<void> {
  const FavoriteRoute({List<_i8.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.FavoritePage();
    },
  );
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i8.PageRouteInfo<void> {
  const HomeRoute({List<_i8.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.SearchPage]
class SearchRoute extends _i8.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({_i9.Key? key, String? query, List<_i8.PageRouteInfo>? children})
    : super(
        SearchRoute.name,
        args: SearchRouteArgs(key: key, query: query),
        rawQueryParams: {'q': query},
        initialChildren: children,
      );

  static const String name = 'SearchRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SearchRouteArgs>(
        orElse: () => SearchRouteArgs(query: queryParams.optString('q')),
      );
      return _i6.SearchPage(key: args.key, query: args.query);
    },
  );
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key, this.query});

  final _i9.Key? key;

  final String? query;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key, query: $query}';
  }
}

/// generated route for
/// [_i7.SettingPage]
class SettingRoute extends _i8.PageRouteInfo<void> {
  const SettingRoute({List<_i8.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingPage();
    },
  );
}
