import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/setting_view_model.dart';
import '../../service/wall_haven_api_service.dart';

@RoutePage()
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final viewModel = GetIt.instance.get<SettingViewModel>();
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel.initSignals();
    _apiKeyController.text = viewModel.apiKey.value ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // API Key settings
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('API Key'),
          subtitle: Watch((context) {
            final key = viewModel.apiKey.value;
            return Text(
              key != null && key.isNotEmpty ? 'Configured' : 'Not configured',
              style: TextStyle(
                color: key != null && key.isNotEmpty
                    ? Colors.green
                    : Colors.grey,
              ),
            );
          }),
          onTap: () => _showApiKeyDialog(context),
        ),
        const Divider(),

        // NSFW toggle
        Watch((context) {
          return SwitchListTile(
            secondary: const Icon(Icons.visibility_off),
            title: const Text('NSFW Content'),
            subtitle: const Text('Requires API Key to enable'),
            value: viewModel.nsfwEnabled.value,
            onChanged: viewModel.apiKey.value != null
                ? (value) => viewModel.setNsfwEnabled(value)
                : null,
          );
        }),
        const Divider(),

        // Theme settings
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: Watch((context) {
            return Text(switch (viewModel.themeMode.value) {
              0 => 'System',
              1 => 'Light',
              2 => 'Dark',
              _ => 'System',
            });
          }),
          onTap: () => _showThemeDialog(context),
        ),
        const Divider(),

        // About
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          subtitle: const Text('WallHaven v1.0.0'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'WallHaven',
              applicationVersion: '1.0.0',
              applicationLegalese: 'A cross-platform wallpaper app powered by WallHaven API',
            );
          },
        ),
      ],
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    _apiKeyController.text = viewModel.apiKey.value ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set API Key'),
          content: TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your WallHaven API Key',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final key = _apiKeyController.text.trim();
                viewModel.setApiKey(key.isEmpty ? null : key);
                // Sync to API service
                GetIt.instance.get<WallHavenApiService>().setApiKey(
                  key.isEmpty ? null : key,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('System'),
                value: 0,
                groupValue: viewModel.themeMode.value,
                onChanged: (value) {
                  viewModel.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('Light'),
                value: 1,
                groupValue: viewModel.themeMode.value,
                onChanged: (value) {
                  viewModel.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('Dark'),
                value: 2,
                groupValue: viewModel.themeMode.value,
                onChanged: (value) {
                  viewModel.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
