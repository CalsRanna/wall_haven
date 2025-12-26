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
import '../../service/wall_haven_api_service.dart';
import '../../view_model/favorite_view_model.dart';
import '../../router/router.gr.dart';
import '../../util/logger_util.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      }
    } catch (e) {
      LoggerUtil.instance.e('Failed to save image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _setAsWallpaper() async {
    if (_wallpaper == null) return;

    try {
      // Download image first
      final file = await DefaultCacheManager().getSingleFile(_wallpaper!.path);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: const Text('Set as Home Screen'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _applyWallpaper(file.path, 'home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Set as Lock Screen'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _applyWallpaper(file.path, 'lock');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.smartphone),
                  title: const Text('Set as Both'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _applyWallpaper(file.path, 'both');
                  },
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      LoggerUtil.instance.e('Failed to set wallpaper', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _applyWallpaper(String path, String target) async {
    // Note: Setting wallpaper requires platform-specific implementation
    // For now, we save to gallery and show instructions
    try {
      await Gal.putImage(path, album: 'WallHaven');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved. Please set wallpaper from gallery.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadWallpaper,
                child: const Text('Retry'),
              ),
            ],
          ),
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
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
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
              // Set wallpaper button
              IconButton(
                icon: const Icon(Icons.wallpaper, color: Colors.white),
                onPressed: _setAsWallpaper,
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
                      // Thumbnail as placeholder
                      CachedNetworkImage(
                        imageUrl: wallpaper.thumbs.large,
                        fit: BoxFit.cover,
                      ),
                      // Full resolution image
                      CachedNetworkImage(
                        imageUrl: wallpaper.path,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white),
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
                  // Resolution and file info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.aspect_ratio,
                            label: 'Resolution',
                            value: wallpaper.resolution,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.storage,
                            label: 'File Size',
                            value: wallpaper.fileSizeFormatted,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.image,
                            label: 'File Type',
                            value: wallpaper.fileType.toUpperCase(),
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.visibility,
                            label: 'Views',
                            value: '${wallpaper.views}',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.favorite,
                            label: 'Favorites',
                            value: '${wallpaper.favorites}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Colors
                  Text('Colors', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: wallpaper.colors.map((color) {
                      final colorValue =
                          int.parse(color.replaceFirst('#', ''), radix: 16) +
                              0xFF000000;
                      return GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: color));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied: $color')),
                          );
                        },
                        child: Tooltip(
                          message: color,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Tags
                  if (wallpaper.tags != null && wallpaper.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: wallpaper.tags!.map((tag) {
                        return ActionChip(
                          label: Text(tag.name),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            context.router.push(SearchRoute(query: tag.name));
                          },
                        );
                      }).toList(),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// Fullscreen image preview with zoom capability
class _FullscreenImageView extends StatelessWidget {
  final String imageUrl;
  final String thumbUrl;

  const _FullscreenImageView({
    required this.imageUrl,
    required this.thumbUrl,
  });

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
