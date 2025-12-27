import 'package:flutter/material.dart';

/// Unified section header widget used across the app.
///
/// Used in Settings page (uppercase) and Detail/Filter pages (regular case).
class SectionHeader extends StatelessWidget {
  final String title;
  final bool uppercase;

  const SectionHeader({
    super.key,
    required this.title,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = uppercase ? title.toUpperCase() : title;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        displayTitle,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
