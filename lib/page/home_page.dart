import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import '../view_model/home_view_model.dart';
import '../router/router.gr.dart';
import 'discover/discover_page.dart';
import 'favorite/favorite_page.dart';
import 'setting/setting_page.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final viewModel = GetIt.instance.get<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wall Haven'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.router.push(SearchRoute());
            },
          ),
        ],
      ),
      body: Watch((context) {
        return switch (viewModel.selectedIndex.value) {
          0 => const DiscoverPage(),
          1 => const FavoritePage(),
          2 => const SettingPage(),
          _ => const DiscoverPage(),
        };
      }),
      bottomNavigationBar: Watch((context) {
        return NavigationBar(
          selectedIndex: viewModel.selectedIndex.value,
          onDestinationSelected: viewModel.switchTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      }),
    );
  }
}
