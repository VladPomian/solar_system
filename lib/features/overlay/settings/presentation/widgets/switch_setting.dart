import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class SwitchSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Map<String, Color> theme;
  final Color cardColor;

  const SwitchSetting({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTheme = title.contains('тема');
    final displayTitle = isTheme ? (value ? 'Тёмная тема' : 'Светлая тема') : title;
    final switchColor = isTheme ? (value ? Colors.amber : Colors.cyan) : theme['primary'];

    return Card(
      color: cardColor,
      child: SwitchListTile(
        title: Text(displayTitle,
            style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
        subtitle: Text(subtitle,
            style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
        value: value,
        onChanged: onChanged,
        activeColor: switchColor,
        inactiveThumbColor: switchColor,
        inactiveTrackColor:
            cardColor == Colors.grey[900]! ? Colors.grey[800] : Colors.grey[400],
      ),
    );
  }
}