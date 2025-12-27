import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/wallpaper_entity.dart';
import '../../model/uploader_entity.dart';
import '../../service/wall_haven_api_service.dart';
import '../../view_model/favorite_view_model.dart';
import '../../router/router.gr.dart';
import '../../util/logger_util.dart';
import '../../widgets/section_header.dart';
import '../../widgets/error_state_view.dart';

@RoutePage()
class DetailPage extends StatefulWidget {
  final String wallpaperId;

  const DetailPage({super.key, @PathParam('id') required this.wallpaperId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _apiService = GetIt.instance.get<WallHavenApiService>();
  final _favoriteViewModel = GetIt.instance.get<FavoriteViewModel>();

  WallpaperEntity? _wallpaper;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    try {
      final wallpaper = await _apiService.getWallpaper(widget.wallpaperId);
      final isFav = await _favoriteViewModel.isFavorite(widget.wallpaperId);
      setState(() {
        _wallpaper = wallpaper;
        _isFavorite = isFav;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadImage() async {
    if (_wallpaper == null || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
            setState(() => _isDownloading = false);
          }
          return;
        }
      }

      // Check if we can save to gallery (handles iOS permission check)
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo library access denied')),
            );
            setState(() => _isDownloading = false);
          }
          return;
        }
      }

      // Download image using cache manager
      final file = await DefaultCacheManager().getSingleFile(_wallpaper!.path);

      // Save to gallery
      await Gal.putImage(file.path, album: 'WallHaven');

      LoggerUtil.instance.i('Image saved: ${_wallpaper!.id}');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
      }
    } catch (e) {
      LoggerUtil.instance.e('Failed to save image', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _openFullscreenPreview() {
    if (_wallpaper == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageView(
          imageUrl: _wallpaper!.path,
          thumbUrl: _wallpaper!.thumbs.large,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(
          message: _error,
          onRetry: _loadWallpaper,
        ),
      );
    }

    final wallpaper = _wallpaper!;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with image
          SliverAppBar(
            expandedHeight: imageHeight,
            pinned: true,
            stretch: true,
            // backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Similar wallpapers button
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                tooltip: 'Similar Wallpapers',
                onPressed: () {
                  context.router.push(
                    SimilarWallpapersRoute(wallpaperId: wallpaper.id),
                  );
                },
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  await _favoriteViewModel.toggleFavorite(wallpaper);
                  setState(() => _isFavorite = !_isFavorite);
                },
              ),
              // Download button
              IconButton(
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download, color: Colors.white),
                onPressed: _isDownloading ? null : _downloadImage,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: _openFullscreenPreview,
                child: Hero(
                  tag: 'wallpaper_${wallpaper.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ProgressiveImage(
                        imageUrl: wallpaper.path,
                        thumbUrl: wallpaper.thumbs.large,
                      ),
                      // Tap indicator
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.aspect_ratio,
                          label: 'Resolution',
                          value: wallpaper.resolution,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.storage,
                          label: 'Size',
                          value: wallpaper.fileSizeFormatted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.visibility_outlined,
                          label: 'Views',
                          value: _formatNumber(wallpaper.views),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite_outline,
                          label: 'Favorites',
                          value: _formatNumber(wallpaper.favorites),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Colors section
                  const SectionHeader(title: 'Colors', uppercase: false),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallpaper.colors.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final color = wallpaper.colors[index];
                        final colorValue =
                            int.parse(color.replaceFirst('#', ''), radix: 16) +
                            0xFF000000;
                        return GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: color));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied: $color'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    colorValue,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Tags section
                  if (wallpaper.tags != null && wallpaper.tags!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Tags', uppercase: false),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: wallpaper.tags!.map((tag) {
                        return ActionChip(
                          label: Text(tag.name),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            context.router.push(SearchRoute(query: tag.name));
                          },
                        );
                      }).toList(),
                    ),
                  ],

                  // Uploader section
                  if (wallpaper.uploader != null) ...[
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Uploaded by', uppercase: false),
                    const SizedBox(height: 12),
                    _UploaderCard(
                      uploader: wallpaper.uploader!,
                      onTap: () {
                        context.router.push(
                          CollectionsRoute(
                            username: wallpaper.uploader!.username,
                          ),
                        );
                      },
                    ),
                  ],

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

class _UploaderCard extends StatelessWidget {
  final UploaderEntity uploader;
  final VoidCallback? onTap;

  const _UploaderCard({
    required this.uploader,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
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
              // Avatar with border
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: CachedNetworkImageProvider(uploader.avatar.medium),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uploader.username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.collections_bookmark_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View collections',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow with background
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen image preview with zoom capability
class _FullscreenImageView extends StatelessWidget {
  final String imageUrl;
  final String thumbUrl;

  const _FullscreenImageView({required this.imageUrl, required this.thumbUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          loadingBuilder: (context, event) => Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Show thumbnail while loading
                CachedNetworkImage(
                  imageUrl: thumbUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Loading indicator
                CircularProgressIndicator(
                  value: event?.expectedTotalBytes != null
                      ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: Colors.white, size: 48),
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}

/// Progressive image loader with thumbnail placeholder and progress indicator
/// Keeps track of download completion to avoid flickering
class _ProgressiveImage extends StatefulWidget {
  final String imageUrl;
  final String thumbUrl;

  const _ProgressiveImage({required this.imageUrl, required this.thumbUrl});

  @override
  State<_ProgressiveImage> createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<_ProgressiveImage> {
  bool _downloadComplete = false;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) {
        // Once download reaches 100%, mark as complete and never show indicator again
        if (progress.progress != null && progress.progress! >= 1) {
          _downloadComplete = true;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail as background
            CachedNetworkImage(imageUrl: widget.thumbUrl, fit: BoxFit.cover),
            // Progress indicator at bottom left (hidden once download complete)
            if (!_downloadComplete)
              Positioned(
                left: 16,
                bottom: 16,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    strokeWidth: 4,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
          ],
        );
      },
      errorWidget: (context, url, error) => Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: widget.thumbUrl, fit: BoxFit.cover),
          const Center(child: Icon(Icons.error, color: Colors.white)),
        ],
      ),
    );
  }
}
