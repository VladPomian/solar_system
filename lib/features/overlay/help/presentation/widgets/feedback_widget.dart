import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class FeedbackWidget extends StatelessWidget {
  final Function(bool) onRate;

  const FeedbackWidget({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Эта статья полезна?',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: AppTheme.getNormalFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onRate(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  foregroundColor: AppTheme.getTextColor(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Да'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onRate(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  foregroundColor: AppTheme.getTextColor(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Нет'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}