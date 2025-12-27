import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/collection_entity.dart';
import '../../view_model/collection_view_model.dart';
import '../../router/router.gr.dart';
import '../../service/wall_haven_api_service.dart';

@RoutePage()
class CollectionsPage extends StatefulWidget {
  final String? username;

  const CollectionsPage({
    super.key,
    @QueryParam('username') this.username,
  });

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final _viewModel = GetIt.instance.get<CollectionViewModel>();
  final _apiService = GetIt.instance.get<WallHavenApiService>();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.username != null && widget.username!.isNotEmpty) {
      _usernameController.text = widget.username!;
      _viewModel.loadUserCollections(widget.username!);
    } else if (_apiService.apiKey != null && _apiService.apiKey!.isNotEmpty) {
      _viewModel.loadMyCollections();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _searchCollections() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      if (_apiService.apiKey != null && _apiService.apiKey!.isNotEmpty) {
        _viewModel.loadMyCollections();
      }
    } else {
      _viewModel.loadUserCollections(username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasApiKey = _apiService.apiKey != null && _apiService.apiKey!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Watch((context) {
          final username = _viewModel.currentUsername.value;
          if (username != null && username.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Collections'),
                Text(
                  '@$username',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }
          return const Text('Collections');
        }),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: hasApiKey
                    ? 'Search by username'
                    : 'Enter username',
                prefixIcon: Icon(
                  Icons.person_search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  child: IconButton.filled(
                    icon: const Icon(Icons.search_rounded, size: 20),
                    onPressed: _searchCollections,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _searchCollections(),
            ),
          ),

          // Collections list
          Expanded(
            child: Watch((context) {
              if (_viewModel.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_viewModel.error.value != null) {
                return _ErrorView(
                  error: _viewModel.error.value!,
                  onRetry: _searchCollections,
                );
              }

              if (_viewModel.collections.value.isEmpty) {
                return _EmptyView(
                  hasApiKey: hasApiKey,
                  hasSearched: _usernameController.text.isNotEmpty,
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _searchCollections(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _viewModel.collections.value.length,
                  itemBuilder: (context, index) {
                    final collection = _viewModel.collections.value[index];
                    return _CollectionCard(
                      collection: collection,
                      onTap: () {
                        final username = _viewModel.currentUsername.value ??
                            _usernameController.text.trim();
                        context.router.push(
                          CollectionDetailRoute(
                            username: username,
                            collectionId: collection.id,
                            collectionLabel: collection.label,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionEntity collection;
  final VoidCallback? onTap;

  const _CollectionCard({
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with gradient-like background
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  collection.public
                      ? Icons.folder_special_rounded
                      : Icons.folder_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            collection.label,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!collection.public)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_rounded,
                                  size: 12,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Private',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${collection.wallpaperCount} wallpapers',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (collection.views > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${collection.views}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorView({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasApiKey;
  final bool hasSearched;

  const _EmptyView({
    required this.hasApiKey,
    this.hasSearched = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasSearched
                    ? Icons.search_off_rounded
                    : Icons.collections_bookmark_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearched
                  ? 'No collections found'
                  : 'Browse Collections',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearched
                  ? 'This user has no public collections.'
                  : hasApiKey
                      ? 'Enter a username to browse their collections,\nor leave empty to view your own.'
                      : 'Enter a username to browse\ntheir public collections.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
