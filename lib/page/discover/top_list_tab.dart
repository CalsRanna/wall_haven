import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/discover_view_model.dart';
import '../../router/router.gr.dart';
import 'wallpaper_grid.dart';

/// Top List tab with time range selector
class TopListTab extends StatefulWidget {
  final TopListViewModel viewModel;

  const TopListTab({super.key, required this.viewModel});

  @override
  State<TopListTab> createState() => _TopListTabState();
}

class _TopListTabState extends State<TopListTab>
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

      return Column(
        children: [
          // Time range selector
          _TopRangeSelector(
            selectedRange: vm.selectedRange.value,
            onChanged: vm.setTopRange,
          ),

          // Content
          Expanded(
            child: _buildContent(vm),
          ),
        ],
      );
    });
  }

  Widget _buildContent(TopListViewModel vm) {
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
  }
}

class _TopRangeSelector extends StatelessWidget {
  final TopRange selectedRange;
  final Future<void> Function(TopRange) onChanged;

  const _TopRangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TopRange.values.map((range) {
            final isSelected = range == selectedRange;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(range.label),
                selected: isSelected,
                onSelected: (_) => onChanged(range),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
