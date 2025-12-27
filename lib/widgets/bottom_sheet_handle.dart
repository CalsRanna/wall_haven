import 'package:flutter/material.dart';

/// Unified bottom sheet drag handle widget used across the app.
///
/// Provides a consistent visual indicator for draggable bottom sheets.
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
