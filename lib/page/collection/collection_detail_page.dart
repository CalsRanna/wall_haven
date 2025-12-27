import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/collection_view_model.dart';
import '../../router/router.gr.dart';
import '../discover/wallpaper_grid.dart';

@RoutePage()
class CollectionDetailPage extends StatefulWidget {
  final String username;
  final int collectionId;
  final String? collectionLabel;

  const CollectionDetailPage({
    super.key,
    @PathParam('username') required this.username,
    @PathParam('id') required this.collectionId,
    @QueryParam('label') this.collectionLabel,
  });

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  final _viewModel = GetIt.instance.get<CollectionViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.loadCollectionWallpapers(
      username: widget.username,
      collectionId: widget.collectionId,
      refresh: true,
    );
  }

  @override
  void dispose() {
    _viewModel.clearWallpapers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionLabel ?? 'Collection'),
      ),
      body: Watch((context) {
        final isLoading = _viewModel.isLoadingWallpapers.value;
        final wallpapers = _viewModel.collectionWallpapers.value;
        final error = _viewModel.wallpapersError.value;

        if (isLoading && wallpapers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && wallpapers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(error),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _viewModel.loadCollectionWallpapers(
                    username: widget.username,
                    collectionId: widget.collectionId,
                    refresh: true,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wallpapers.isEmpty) {
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
                  'This collection is empty',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _viewModel.loadCollectionWallpapers(
            username: widget.username,
            collectionId: widget.collectionId,
            refresh: true,
          ),
          child: WallpaperGrid(
            wallpapers: wallpapers,
            hasMore: _viewModel.hasMoreWallpapers.value,
            isLoading: isLoading,
            onLoadMore: () => _viewModel.loadMoreWallpapers(
              username: widget.username,
              collectionId: widget.collectionId,
            ),
            onTap: (wallpaper) {
              context.router.push(DetailRoute(wallpaperId: wallpaper.id));
            },
          ),
        );
      }),
    );
  }
}
