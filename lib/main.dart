import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'database/database.dart';
import 'di.dart';
import 'router/router.dart';
import 'util/shared_preference_util.dart';
import 'util/logger_util.dart';
import 'view_model/setting_view_model.dart';
import 'service/wall_haven_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await Database.instance.ensureInitialized();

  // Initialize preferences
  await SharedPreferenceUtil.instance.ensureInitialized();

  // Initialize dependency injection
  DI.ensureInitialized();

  // Sync API Key to service
  final apiKey = SharedPreferenceUtil.instance.apiKey;
  if (apiKey != null && apiKey.isNotEmpty) {
    GetIt.instance.get<WallHavenApiService>().setApiKey(apiKey);
  }

  // Disable Signals debug output
  SignalsObserver.instance = null;

  LoggerUtil.instance.i('WallHaven app started');

  runApp(const WallHavenApp());
}

class WallHavenApp extends StatelessWidget {
  const WallHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingViewModel = GetIt.instance.get<SettingViewModel>();

    return Watch((context) {
      final themeMode = switch (settingViewModel.themeMode.value) {
        1 => ThemeMode.light,
        2 => ThemeMode.dark,
        _ => ThemeMode.system,
      };

      return MaterialApp.router(
        title: 'WallHaven',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          fontFamily: 'WireOne',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          fontFamily: 'WireOne',
        ),
        themeMode: themeMode,
        routerConfig: appRouter.config(),
      );
    });
  }
}
