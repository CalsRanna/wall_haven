import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/discover_view_model.dart';
import '../../router/router.gr.dart';
import 'wallpaper_grid.dart';

/// A single tab page with KeepAlive to preserve scroll position and state
class WallpaperListTab extends StatefulWidget {
  final DiscoverTabViewModel viewModel;

  const WallpaperListTab({super.key, required this.viewModel});

  @override
  State<WallpaperListTab> createState() => _WallpaperListTabState();
}

class _WallpaperListTabState extends State<WallpaperListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Watch((context) {
      final vm = widget.viewModel;

      if (vm.error.value != null && vm.wallpapers.value.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(vm.error.value!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: vm.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (vm.isLoading.value && vm.wallpapers.value.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (vm.wallpapers.value.isEmpty) {
        return const Center(child: Text('No wallpapers'));
      }

      return RefreshIndicator(
        onRefresh: vm.refresh,
        child: WallpaperGrid(
          wallpapers: vm.wallpapers.value,
          onLoadMore: vm.loadMore,
          hasMore: vm.hasMore.value,
          isLoading: vm.isLoading.value,
          onTap: (wallpaper) {
            context.router.push(DetailRoute(wallpaperId: wallpaper.id));
          },
        ),
      );
    });
  }
}
