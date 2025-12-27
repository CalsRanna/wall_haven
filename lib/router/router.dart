import 'package:auto_route/auto_route.dart';
import 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: DetailRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: SettingRoute.page),
        AutoRoute(page: CacheFilesRoute.page),
      ];
}

final appRouter = AppRouter();
