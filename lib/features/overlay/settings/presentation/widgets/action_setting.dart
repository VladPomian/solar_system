import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class ActionSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Map<String, Color> theme;
  final Color cardColor;

  const ActionSetting({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.theme,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: theme['icon']),
        title: Text(title,
            style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
        subtitle: Text(subtitle,
            style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
        trailing: Icon(Icons.arrow_forward_ios, color: theme['icon'], size: 16),
        onTap: onTap,
      ),
    );
  }
}