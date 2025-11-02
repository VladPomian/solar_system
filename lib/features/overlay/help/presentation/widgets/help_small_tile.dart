import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class HelpSmallTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const HelpSmallTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: AppTheme.getBodyFontSize(),
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.getSecondaryTextColor(context)),
        ],
      ),
    );
  }
}