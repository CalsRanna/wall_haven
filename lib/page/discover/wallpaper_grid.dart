import 'package:flutter/material.dart';
import '../../model/wallpaper_entity.dart';
import 'wallpaper_card.dart';

class WallpaperGrid extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final void Function(WallpaperEntity)? onTap;

  const WallpaperGrid({
    super.key,
    required this.wallpapers,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoading) {
          onLoadMore?.call();
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive column count
          int crossAxisCount;
          if (constraints.maxWidth >= 1200) {
            crossAxisCount = 5;
          } else if (constraints.maxWidth >= 900) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: wallpapers.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= wallpapers.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final wallpaper = wallpapers[index];
              return WallpaperCard(
                wallpaper: wallpaper,
                onTap: () => onTap?.call(wallpaper),
              );
            },
          );
        },
      ),
    );
  }
}
