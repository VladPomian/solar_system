import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class SliderSetting extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Map<String, Color> theme;
  final Color cardColor;

  const SliderSetting({
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
            Text('Скорость речи',
                style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
            const SizedBox(height: 4),
            Text('Регулировка скорости голосового ответа',
                style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: theme['primary'],
                inactiveTrackColor: Colors.grey[600],
                thumbColor: theme['primary'],
                overlayColor: theme['primary']!.withOpacity(0.2),
                valueIndicatorColor: theme['primary'],
              ),
              child: Slider(
                value: value,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(value * 10).round()}',
                onChanged: onChanged,
              ),
            ),
            Text('${(value * 10).round()}/10',
                style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
          ],
        ),
      ),
    );
  }
}