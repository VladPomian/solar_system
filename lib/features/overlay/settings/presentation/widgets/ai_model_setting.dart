import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class AIModelSetting extends StatelessWidget {
  final AIModel value;
  final ValueChanged<AIModel> onChanged;
  final Map<String, Color> theme;
  final Color cardColor;
  final BuildContext context;

  const AIModelSetting({
    super.key,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.cardColor,
    required this.context,
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
            Text('Модель ИИ',
                style: TextStyle(color: theme['text'], fontSize: AppTheme.getSubtitleFontSize())),
            const SizedBox(height: 4),
            Text('Выберите модель ИИ для ответов голосового помощника',
                style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
            const SizedBox(height: 12),
            DropdownButton<AIModel>(
              value: value,
              isExpanded: true,
              items: AIModel.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.displayName,
                            style: TextStyle(
                                color: AppTheme.getTextColor(context), fontSize: AppTheme.getBodyFontSize())),
                      ))
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
              dropdownColor: cardColor,
              focusColor: theme['primary']!.withOpacity(0.2),
              style: TextStyle(color: AppTheme.getTextColor(context), fontSize: AppTheme.getBodyFontSize()),
              underline: Container(height: 2, color: theme['secondary']),
            ),
            const SizedBox(height: 8),
            Text(value.description,
                style: TextStyle(color: theme['secondary'], fontSize: AppTheme.getBodyFontSize())),
          ],
        ),
      ),
    );
  }
}