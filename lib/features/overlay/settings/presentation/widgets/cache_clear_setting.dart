import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/cache_service.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class CacheClearSetting extends StatelessWidget {
  final int cacheSize;
  final bool isLoading;
  final VoidCallback onClear;
  final Map<String, Color> theme;
  final Color cardColor;

  const CacheClearSetting({
    super.key,
    required this.cacheSize,
    required this.isLoading,
    required this.onClear,
    required this.theme,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final sizeText = CacheService.formatSize(cacheSize);

    return Card(
      color: cardColor,
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(theme['icon']),
                ),
              )
            : Icon(Icons.delete_outline, color: theme['icon']),
        title: Text(
          'Очистить кэш',
          style: TextStyle(
            color: theme['text'],
            fontSize: AppTheme.getSubtitleFontSize(),
          ),
        ),
        subtitle: Text(
          'Очистить временные файлы ($sizeText)',
          style: TextStyle(
            color: theme['secondary'],
            fontSize: AppTheme.getBodyFontSize(),
          ),
        ),
        trailing: isLoading
            ? const SizedBox(width: 16)
            : Icon(Icons.arrow_forward_ios, color: theme['icon'], size: 16),
        onTap: isLoading ? null : onClear,
        enabled: !isLoading,
      ),
    );
  }
}