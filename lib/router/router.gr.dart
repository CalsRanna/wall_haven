// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:wall_haven/page/detail/detail_page.dart' as _i1;
import 'package:wall_haven/page/discover/discover_page.dart' as _i2;
import 'package:wall_haven/page/favorite/favorite_page.dart' as _i3;
import 'package:wall_haven/page/home_page.dart' as _i4;
import 'package:wall_haven/page/search/search_page.dart' as _i5;
import 'package:wall_haven/page/setting/setting_page.dart' as _i6;

/// generated route for
/// [_i1.DetailPage]
class DetailRoute extends _i7.PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    _i8.Key? key,
    required String wallpaperId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(key: key, wallpaperId: wallpaperId),
         rawPathParams: {'id': wallpaperId},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(wallpaperId: pathParams.getString('id')),
      );
      return _i1.DetailPage(key: args.key, wallpaperId: args.wallpaperId);
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({this.key, required this.wallpaperId});

  final _i8.Key? key;

  final String wallpaperId;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, wallpaperId: $wallpaperId}';
  }
}

/// generated route for
/// [_i2.DiscoverPage]
class DiscoverRoute extends _i7.PageRouteInfo<void> {
  const DiscoverRoute({List<_i7.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.DiscoverPage();
    },
  );
}

/// generated route for
/// [_i3.FavoritePage]
class FavoriteRoute extends _i7.PageRouteInfo<void> {
  const FavoriteRoute({List<_i7.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.FavoritePage();
    },
  );
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.SearchPage]
class SearchRoute extends _i7.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({_i8.Key? key, String? query, List<_i7.PageRouteInfo>? children})
    : super(
        SearchRoute.name,
        args: SearchRouteArgs(key: key, query: query),
        rawQueryParams: {'q': query},
        initialChildren: children,
      );

  static const String name = 'SearchRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SearchRouteArgs>(
        orElse: () => SearchRouteArgs(query: queryParams.optString('q')),
      );
      return _i5.SearchPage(key: args.key, query: args.query);
    },
  );
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key, this.query});

  final _i8.Key? key;

  final String? query;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key, query: $query}';
  }
}

/// generated route for
/// [_i6.SettingPage]
class SettingRoute extends _i7.PageRouteInfo<void> {
  const SettingRoute({List<_i7.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingPage();
    },
  );
}
