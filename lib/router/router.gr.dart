// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/material.dart' as _i12;
import 'package:wall_haven/page/collection/collection_detail_page.dart' as _i2;
import 'package:wall_haven/page/collection/collections_page.dart' as _i3;
import 'package:wall_haven/page/detail/detail_page.dart' as _i4;
import 'package:wall_haven/page/detail/similar_wallpapers_page.dart' as _i10;
import 'package:wall_haven/page/discover/discover_page.dart' as _i5;
import 'package:wall_haven/page/favorite/favorite_page.dart' as _i6;
import 'package:wall_haven/page/home_page.dart' as _i7;
import 'package:wall_haven/page/search/search_page.dart' as _i8;
import 'package:wall_haven/page/setting/cache_files_page.dart' as _i1;
import 'package:wall_haven/page/setting/setting_page.dart' as _i9;

/// generated route for
/// [_i1.CacheFilesPage]
class CacheFilesRoute extends _i11.PageRouteInfo<void> {
  const CacheFilesRoute({List<_i11.PageRouteInfo>? children})
    : super(CacheFilesRoute.name, initialChildren: children);

  static const String name = 'CacheFilesRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i1.CacheFilesPage();
    },
  );
}

/// generated route for
/// [_i2.CollectionDetailPage]
class CollectionDetailRoute
    extends _i11.PageRouteInfo<CollectionDetailRouteArgs> {
  CollectionDetailRoute({
    _i12.Key? key,
    required String username,
    required int collectionId,
    String? collectionLabel,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         CollectionDetailRoute.name,
         args: CollectionDetailRouteArgs(
           key: key,
           username: username,
           collectionId: collectionId,
           collectionLabel: collectionLabel,
         ),
         rawPathParams: {'username': username, 'id': collectionId},
         rawQueryParams: {'label': collectionLabel},
         initialChildren: children,
       );

  static const String name = 'CollectionDetailRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<CollectionDetailRouteArgs>(
        orElse: () => CollectionDetailRouteArgs(
          username: pathParams.getString('username'),
          collectionId: pathParams.getInt('id'),
          collectionLabel: queryParams.optString('label'),
        ),
      );
      return _i2.CollectionDetailPage(
        key: args.key,
        username: args.username,
        collectionId: args.collectionId,
        collectionLabel: args.collectionLabel,
      );
    },
  );
}

class CollectionDetailRouteArgs {
  const CollectionDetailRouteArgs({
    this.key,
    required this.username,
    required this.collectionId,
    this.collectionLabel,
  });

  final _i12.Key? key;

  final String username;

  final int collectionId;

  final String? collectionLabel;

  @override
  String toString() {
    return 'CollectionDetailRouteArgs{key: $key, username: $username, collectionId: $collectionId, collectionLabel: $collectionLabel}';
  }
}

/// generated route for
/// [_i3.CollectionsPage]
class CollectionsRoute extends _i11.PageRouteInfo<CollectionsRouteArgs> {
  CollectionsRoute({
    _i12.Key? key,
    String? username,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         CollectionsRoute.name,
         args: CollectionsRouteArgs(key: key, username: username),
         rawQueryParams: {'username': username},
         initialChildren: children,
       );

  static const String name = 'CollectionsRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<CollectionsRouteArgs>(
        orElse: () =>
            CollectionsRouteArgs(username: queryParams.optString('username')),
      );
      return _i3.CollectionsPage(key: args.key, username: args.username);
    },
  );
}

class CollectionsRouteArgs {
  const CollectionsRouteArgs({this.key, this.username});

  final _i12.Key? key;

  final String? username;

  @override
  String toString() {
    return 'CollectionsRouteArgs{key: $key, username: $username}';
  }
}

/// generated route for
/// [_i4.DetailPage]
class DetailRoute extends _i11.PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    _i12.Key? key,
    required String wallpaperId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(key: key, wallpaperId: wallpaperId),
         rawPathParams: {'id': wallpaperId},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(wallpaperId: pathParams.getString('id')),
      );
      return _i4.DetailPage(key: args.key, wallpaperId: args.wallpaperId);
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({this.key, required this.wallpaperId});

  final _i12.Key? key;

  final String wallpaperId;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, wallpaperId: $wallpaperId}';
  }
}

/// generated route for
/// [_i5.DiscoverPage]
class DiscoverRoute extends _i11.PageRouteInfo<void> {
  const DiscoverRoute({List<_i11.PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i5.DiscoverPage();
    },
  );
}

/// generated route for
/// [_i6.FavoritePage]
class FavoriteRoute extends _i11.PageRouteInfo<void> {
  const FavoriteRoute({List<_i11.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i6.FavoritePage();
    },
  );
}

/// generated route for
/// [_i7.HomePage]
class HomeRoute extends _i11.PageRouteInfo<void> {
  const HomeRoute({List<_i11.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i7.HomePage();
    },
  );
}

/// generated route for
/// [_i8.SearchPage]
class SearchRoute extends _i11.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({
    _i12.Key? key,
    String? query,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         SearchRoute.name,
         args: SearchRouteArgs(key: key, query: query),
         rawQueryParams: {'q': query},
         initialChildren: children,
       );

  static const String name = 'SearchRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SearchRouteArgs>(
        orElse: () => SearchRouteArgs(query: queryParams.optString('q')),
      );
      return _i8.SearchPage(key: args.key, query: args.query);
    },
  );
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key, this.query});

  final _i12.Key? key;

  final String? query;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key, query: $query}';
  }
}

/// generated route for
/// [_i9.SettingPage]
class SettingRoute extends _i11.PageRouteInfo<void> {
  const SettingRoute({List<_i11.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i9.SettingPage();
    },
  );
}

/// generated route for
/// [_i10.SimilarWallpapersPage]
class SimilarWallpapersRoute
    extends _i11.PageRouteInfo<SimilarWallpapersRouteArgs> {
  SimilarWallpapersRoute({
    _i12.Key? key,
    required String wallpaperId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         SimilarWallpapersRoute.name,
         args: SimilarWallpapersRouteArgs(key: key, wallpaperId: wallpaperId),
         rawPathParams: {'id': wallpaperId},
         initialChildren: children,
       );

  static const String name = 'SimilarWallpapersRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SimilarWallpapersRouteArgs>(
        orElse: () =>
            SimilarWallpapersRouteArgs(wallpaperId: pathParams.getString('id')),
      );
      return _i10.SimilarWallpapersPage(
        key: args.key,
        wallpaperId: args.wallpaperId,
      );
    },
  );
}

class SimilarWallpapersRouteArgs {
  const SimilarWallpapersRouteArgs({this.key, required this.wallpaperId});

  final _i12.Key? key;

  final String wallpaperId;

  @override
  String toString() {
    return 'SimilarWallpapersRouteArgs{key: $key, wallpaperId: $wallpaperId}';
  }
}
