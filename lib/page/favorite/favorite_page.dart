import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../view_model/favorite_view_model.dart';
import '../../router/router.gr.dart';

@RoutePage()
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final viewModel = GetIt.instance.get<FavoriteViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.initSignals();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (viewModel.isLoading.value && viewModel.favorites.value.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (viewModel.favorites.value.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No favorites yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive column count (same as WallpaperGrid)
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
            itemCount: viewModel.favorites.value.length,
            itemBuilder: (context, index) {
              final favorite = viewModel.favorites.value[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    context.router.push(
                      DetailRoute(wallpaperId: favorite.wallpaperId),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: favorite.thumbnailUrl,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
