import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class FontSizeSetting extends StatelessWidget {
  final FontSizeOption value;
  final ValueChanged<FontSizeOption> onChanged;
  final Map<String, Color> theme;
  final Color cardColor;

  const FontSizeSetting({
    super.key,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Размер шрифта',
                style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
            const SizedBox(height: 4),
            Text('Настройте размер шрифта для всего приложения',
                style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
            const SizedBox(height: 12),
            SegmentedButton<FontSizeOption>(
              segments: const [
                ButtonSegment(value: FontSizeOption.small, label: Text('Маленький')),
                ButtonSegment(value: FontSizeOption.medium, label: Text('Средний')),
                ButtonSegment(value: FontSizeOption.large, label: Text('Большой')),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                foregroundColor: AppTheme.getTextColor(context),
                selectedForegroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                selectedBackgroundColor: theme['primary'],
                backgroundColor: Theme.of(context).cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}