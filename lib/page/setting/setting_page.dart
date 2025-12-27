import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import '../../view_model/setting_view_model.dart';
import '../../service/wall_haven_api_service.dart';
import '../../util/api_cache_util.dart';
import '../../router/router.gr.dart';
import '../../widgets/section_header.dart';
import '../../widgets/bottom_sheet_handle.dart';

@RoutePage()
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final viewModel = GetIt.instance.get<SettingViewModel>();
  final _apiKeyController = TextEditingController();
  String _cacheSize = '0 B';

  @override
  void initState() {
    super.initState();
    viewModel.initSignals();
    _apiKeyController.text = viewModel.apiKey.value ?? '';
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await ApiCacheUtil.instance.getCacheSizeFormatted();
    if (mounted) {
      setState(() => _cacheSize = size);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Account Section
        const SectionHeader(title: 'Account'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            Watch((context) {
              final key = viewModel.apiKey.value;
              final isConfigured = key != null && key.isNotEmpty;
              return _SettingsTile(
                icon: Icons.key_rounded,
                iconColor: isConfigured ? colorScheme.primary : colorScheme.outline,
                title: 'API Key',
                subtitle: isConfigured ? 'Configured' : 'Not configured',
                trailing: isConfigured
                    ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                onTap: () => _showApiKeyDialog(context),
              );
            }),
            Watch((context) {
              final hasApiKey = viewModel.apiKey.value != null && viewModel.apiKey.value!.isNotEmpty;
              return _SettingsTile(
                icon: Icons.eighteen_up_rating_rounded,
                iconColor: viewModel.nsfwEnabled.value ? colorScheme.error : colorScheme.outline,
                title: 'NSFW Content',
                subtitle: hasApiKey ? 'Show adult content' : 'Requires API Key',
                trailing: Switch(
                  value: viewModel.nsfwEnabled.value,
                  onChanged: hasApiKey ? (value) => viewModel.setNsfwEnabled(value) : null,
                ),
                enabled: hasApiKey,
              );
            }),
          ],
        ),

        const SizedBox(height: 24),

        // Appearance Section
        const SectionHeader(title: 'Appearance'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            Watch((context) {
              final themeName = switch (viewModel.themeMode.value) {
                1 => 'Light',
                2 => 'Dark',
                _ => 'System',
              };
              final themeIcon = switch (viewModel.themeMode.value) {
                1 => Icons.light_mode_rounded,
                2 => Icons.dark_mode_rounded,
                _ => Icons.brightness_auto_rounded,
              };
              return _SettingsTile(
                icon: themeIcon,
                iconColor: colorScheme.primary,
                title: 'Theme',
                subtitle: themeName,
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                onTap: () => _showThemeBottomSheet(context),
              );
            }),
          ],
        ),

        const SizedBox(height: 24),

        // Storage Section
        const SectionHeader(title: 'Storage'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.cached_rounded,
              iconColor: colorScheme.tertiary,
              title: 'Cache',
              subtitle: _cacheSize,
              trailing: TextButton(
                onPressed: () => _showClearCacheDialog(context),
                child: const Text('Clear'),
              ),
            ),
            _SettingsTile(
              icon: Icons.folder_open_rounded,
              iconColor: colorScheme.tertiary,
              title: 'Cache Files',
              subtitle: 'View cached API responses',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
              onTap: () => context.router.push(const CacheFilesRoute()),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // About Section
        const SectionHeader(title: 'About'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: colorScheme.secondary,
              title: 'WallHaven',
              subtitle: 'Version 1.0.0',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
              onTap: () => _showAboutBottomSheet(context),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    _apiKeyController.text = viewModel.apiKey.value ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApiKeyBottomSheet(
        controller: _apiKeyController,
        onSave: () {
          final key = _apiKeyController.text.trim();
          viewModel.setApiKey(key.isEmpty ? null : key);
          GetIt.instance.get<WallHavenApiService>().setApiKey(
            key.isEmpty ? null : key,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeBottomSheet(
        currentTheme: viewModel.themeMode.value,
        onSelect: (value) {
          viewModel.setThemeMode(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Clear Cache'),
        content: Text('This will delete $_cacheSize of cached data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiCacheUtil.instance.clearCache();
              await _loadCacheSize();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.wallpaper_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'WallHaven',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A beautiful wallpaper app powered by the WallHaven API. Browse, search, and download stunning wallpapers for your devices.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Could open wallhaven.cc
                      },
                      icon: const Icon(Icons.language),
                      label: const Text('WallHaven'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Card Container
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: enabled ? null : colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled ? colorScheme.onSurfaceVariant : colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// API Key Bottom Sheet
class _ApiKeyBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const _ApiKeyBottomSheet({
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: BottomSheetHandle()),
          const SizedBox(height: 24),
          Text(
            'API Key',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your WallHaven API key to access NSFW content and your collections.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Paste your API key here',
              prefixIcon: const Icon(Icons.key_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Theme Bottom Sheet
class _ThemeBottomSheet extends StatelessWidget {
  final int currentTheme;
  final ValueChanged<int> onSelect;

  const _ThemeBottomSheet({
    required this.currentTheme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 24),
          Text(
            'Choose Theme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.brightness_auto_rounded,
                label: 'System',
                isSelected: currentTheme == 0,
                onTap: () => onSelect(0),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'Light',
                isSelected: currentTheme == 1,
                onTap: () => onSelect(1),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                isSelected: currentTheme == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
