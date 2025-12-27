import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../model/wallpaper_entity.dart';
import '../../service/wall_haven_api_service.dart';
import '../../router/router.gr.dart';
import '../discover/wallpaper_grid.dart';

@RoutePage()
class SimilarWallpapersPage extends StatefulWidget {
  final String wallpaperId;

  const SimilarWallpapersPage({
    super.key,
    @PathParam('id') required this.wallpaperId,
  });

  @override
  State<SimilarWallpapersPage> createState() => _SimilarWallpapersPageState();
}

class _SimilarWallpapersPageState extends State<SimilarWallpapersPage> {
  final _apiService = GetIt.instance.get<WallHavenApiService>();

  List<WallpaperEntity> _wallpapers = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  Future<void> _loadWallpapers({bool loadMore = false}) async {
    if (_isLoading && loadMore) return;

    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _error = null;
        _currentPage = 1;
      }
    });

    try {
      final result = await _apiService.search(
        query: 'like:${widget.wallpaperId}',
        page: _currentPage,
      );

      setState(() {
        final filtered = result.data
            .where((w) => w.id != widget.wallpaperId)
            .toList();

        if (loadMore) {
          _wallpapers.addAll(filtered);
        } else {
          _wallpapers = filtered;
        }
        _hasMore = result.meta.currentPage < result.meta.lastPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    await _loadWallpapers(loadMore: true);
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadWallpapers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Wallpapers'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _wallpapers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No similar wallpapers found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: WallpaperGrid(
        wallpapers: _wallpapers,
        hasMore: _hasMore,
        isLoading: _isLoading,
        onLoadMore: _loadMore,
        onTap: (wallpaper) {
          context.router.push(DetailRoute(wallpaperId: wallpaper.id));
        },
      ),
    );
  }
}
