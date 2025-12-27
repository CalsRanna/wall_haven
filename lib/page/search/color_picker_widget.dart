import 'package:flutter/material.dart';

/// Color picker widget with preset Wallhaven colors
class ColorPickerWidget extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  /// Preset colors from Wallhaven API
  static const List<String> presetColors = [
    '660000',
    'cc0000',
    'ea4c88',
    '993399',
    '663399',
    '0066bf',
    '0099cc',
    '66cccc',
    '77cc33',
    '669900',
    'cccc33',
    'ffcc00',
    'ff6600',
    'cc6633',
    '996633',
    '663300',
    '999999',
    '000000',
    '424153',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Clear color button
        _ColorCircle(
          color: null,
          isSelected: selectedColor == null,
          onTap: () => onColorSelected(null),
          child: Icon(
            Icons.clear,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        // Preset colors
        ...presetColors.map(
          (hex) => _ColorCircle(
            color: Color(int.parse('FF$hex', radix: 16)),
            isSelected: selectedColor == hex,
            onTap: () => onColorSelected(hex),
          ),
        ),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color ?? colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? colorScheme.primary).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
