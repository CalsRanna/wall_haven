import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../view_model/discover_view_model.dart';
import 'wallpaper_list_tab.dart';
import 'top_list_tab.dart';

@RoutePage()
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  final viewModel = GetIt.instance.get<DiscoverViewModel>();
  late final TabController _tabController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: viewModel.currentIndex.value,
    );
    _pageController = PageController(initialPage: viewModel.currentIndex.value);

    _tabController.addListener(_onTabChanged);
    viewModel.initSignals();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final index = _tabController.index;
    viewModel.onPageChanged(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    viewModel.onPageChanged(index);
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Latest'),
            Tab(icon: Icon(Icons.trending_up), text: 'Popular'),
            Tab(icon: Icon(Icons.shuffle), text: 'Random'),
            Tab(icon: Icon(Icons.star), text: 'Top'),
          ],
        ),

        // PageView with four tabs
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              WallpaperListTab(viewModel: viewModel.latestViewModel),
              WallpaperListTab(viewModel: viewModel.popularViewModel),
              WallpaperListTab(viewModel: viewModel.randomViewModel),
              TopListTab(viewModel: viewModel.topListViewModel),
            ],
          ),
        ),
      ],
    );
  }
}
