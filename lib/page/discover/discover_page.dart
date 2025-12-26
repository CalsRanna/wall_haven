import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/discover_view_model.dart';
import '../../router/router.gr.dart';
import 'wallpaper_grid.dart';

@RoutePage()
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final viewModel = GetIt.instance.get<DiscoverViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.initSignals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sorting tabs
        Watch((context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'date_added',
                  label: Text('Latest'),
                  icon: Icon(Icons.access_time),
                ),
                ButtonSegment(
                  value: 'views',
                  label: Text('Popular'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment(
                  value: 'random',
                  label: Text('Random'),
                  icon: Icon(Icons.shuffle),
                ),
              ],
              selected: {viewModel.sorting.value},
              onSelectionChanged: (selected) {
                viewModel.changeSorting(selected.first);
              },
            ),
          );
        }),

        // Wallpaper grid
        Expanded(
          child: Watch((context) {
            if (viewModel.error.value != null &&
                viewModel.wallpapers.value.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(viewModel.error.value!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: viewModel.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.isLoading.value &&
                viewModel.wallpapers.value.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.wallpapers.value.isEmpty) {
              return const Center(child: Text('No wallpapers'));
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: WallpaperGrid(
                wallpapers: viewModel.wallpapers.value,
                onLoadMore: viewModel.loadMore,
                hasMore: viewModel.hasMore.value,
                isLoading: viewModel.isLoading.value,
                onTap: (wallpaper) {
                  context.router.push(DetailRoute(wallpaperId: wallpaper.id));
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
