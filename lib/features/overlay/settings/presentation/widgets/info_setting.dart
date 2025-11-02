import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class InfoSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, Color> theme;
  final Color cardColor;
  final VoidCallback onTap;

  const InfoSetting({
    super.key,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: ListTile(
        title: Text(title,
            style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
        subtitle: Text(subtitle,
            style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: theme['icon']),
          onPressed: onTap,
          tooltip: 'Подробнее о $title',
        ),
      ),
    );
  }
}