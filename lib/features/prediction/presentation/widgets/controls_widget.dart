import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class ControlsWidget extends StatelessWidget {
  final int selectedMode;
  final bool showOnlyExceed;
  final Function(int) onModeChanged;
  final Function(bool)? onShowExceedChanged;

  const ControlsWidget({
    super.key,
    required this.selectedMode,
    required this.showOnlyExceed,
    required this.onModeChanged,
    this.onShowExceedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.getTextColor(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppTheme.getBackgroundColor(context),
            textTheme: TextTheme(
              bodyMedium: TextStyle(
                color: textColor,
                fontSize: AppTheme.getBodyFontSize(),
              ),
            ),
          ),
          child: DropdownButton<int>(
            value: selectedMode,
            items: [
              DropdownMenuItem(
                value: 0,
                child: Text(
                  'Линейный график',
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppTheme.getBodyFontSize(),
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text(
                  'Столбчатый график',
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppTheme.getBodyFontSize(),
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text(
                  'Круговая диаграмма',
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppTheme.getBodyFontSize(),
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text(
                  'Таблица',
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppTheme.getBodyFontSize(),
                  ),
                ),
              ),
            ],
            onChanged: (val) => onModeChanged(val!),
            style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context),
              fontSize: AppTheme.getBodyFontSize(),
            ),
            underline: const SizedBox(),
            dropdownColor: AppTheme.getBackgroundColor(context),
            iconEnabledColor: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        if (selectedMode == 3 && onShowExceedChanged != null)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: showOnlyExceed,
                  onChanged: onShowExceedChanged,
                  activeColor: primaryColor,
                  inactiveThumbColor: Colors.grey,
                ),
                Flexible(
                  child: Text(
                    'Только превышения',
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                      fontSize: AppTheme.getBodyFontSize(),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}