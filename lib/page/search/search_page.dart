import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/wallpaper_entity.dart';
import '../../model/search_filter.dart';
import '../../service/wall_haven_api_service.dart';
import '../../router/router.gr.dart';
import 'search_filter_panel.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  final String? query;

  const SearchPage({super.key, @QueryParam('q') this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _apiService = GetIt.instance.get<WallHavenApiService>();
  final _searchController = TextEditingController();

  List<WallpaperEntity> _wallpapers = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  SearchFilter _filter = const SearchFilter();

  @override
  void initState() {
    super.initState();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchController.text = widget.query!;
      _search();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search({bool loadMore = false}) async {
    if (_isLoading) return;

    final query = _searchController.text.trim();
    // Allow search with empty query if filters are active
    if (query.isEmpty && !_filter.hasActiveFilters) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (!loadMore) {
        _currentPage = 1;
        _wallpapers = [];
      }
    });

    try {
      final result = await _apiService.search(
        query: query.isNotEmpty ? query : null,
        page: _currentPage,
        categories: _filter.categoriesParam,
        purity: _filter.puritiesParam,
        sorting: _filter.sorting.value,
        order: _filter.order.value,
        atleast: _filter.atleast,
        resolutions: _filter.resolutions,
        ratios: _filter.ratios,
        colors: _filter.colors,
      );

      setState(() {
        if (loadMore) {
          _wallpapers.addAll(result.data);
        } else {
          _wallpapers = result.data;
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
    await _search(loadMore: true);
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterPanel(
        filter: _filter,
        onFilterChanged: (filter) {
          _filter = filter;
        },
        onApply: () {
          Navigator.pop(context);
          setState(() {});
          // Allow search without query when filters are active
          if (_searchController.text.isNotEmpty || _filter.hasActiveFilters) {
            _search();
          }
        },
        onReset: () {
          _filter = const SearchFilter();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search wallpapers...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _wallpapers = [];
                });
              },
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          // Filter button with indicator
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showFilterPanel,
              ),
              if (_filter.hasActiveFilters)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
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
            FilledButton(onPressed: _search, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for wallpapers',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_filter.hasActiveFilters) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showFilterPanel,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filters active'),
              ),
            ],
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            _hasMore &&
            !_isLoading) {
          _loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        itemCount: _wallpapers.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _wallpapers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final wallpaper = _wallpapers[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.router.push(DetailRoute(wallpaperId: wallpaper.id));
              },
              child: CachedNetworkImage(
                imageUrl: wallpaper.thumbs.large,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
