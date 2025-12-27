import 'package:get_it/get_it.dart';
import 'service/wall_haven_api_service.dart';
import 'view_model/home_view_model.dart';
import 'view_model/discover_view_model.dart';
import 'view_model/favorite_view_model.dart';
import 'view_model/setting_view_model.dart';
import 'view_model/collection_view_model.dart';

class DI {
  static void ensureInitialized() {
    final instance = GetIt.instance;

    // Services
    instance.registerLazySingleton<WallHavenApiService>(
      () => WallHavenApiService(),
    );

    // ViewModel
    instance.registerLazySingleton<HomeViewModel>(() => HomeViewModel());
    instance.registerLazySingleton<DiscoverViewModel>(
      () => DiscoverViewModel(),
    );
    instance.registerLazySingleton<FavoriteViewModel>(
      () => FavoriteViewModel(),
    );
    instance.registerLazySingleton<SettingViewModel>(() => SettingViewModel());
    instance.registerLazySingleton<CollectionViewModel>(
      () => CollectionViewModel(),
    );
  }
}
