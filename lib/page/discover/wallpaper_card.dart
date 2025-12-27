import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/wallpaper_entity.dart';
import '../../widgets/loading_placeholder.dart';

class WallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback? onTap;

  const WallpaperCard({super.key, required this.wallpaper, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: wallpaper.thumbs.large,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const LoadingPlaceholder(),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${wallpaper.favorites}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
