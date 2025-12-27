import 'package:flutter/material.dart';

/// Unified loading placeholder widget used across the app.
///
/// Replaces hardcoded `Colors.grey[300]` with theme-aware colors
/// to support both light and dark modes properly.
class LoadingPlaceholder extends StatelessWidget {
  final double strokeWidth;

  const LoadingPlaceholder({
    super.key,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
