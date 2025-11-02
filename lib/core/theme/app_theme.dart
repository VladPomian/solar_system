import 'package:flutter/material.dart';

enum FontSizeOption { small, medium, large }

class AppTheme {
  // Переменная для хранения текущего размера шрифта
  static FontSizeOption _currentFontSize = FontSizeOption.medium;

  // Метод для установки размера шрифта
  static void setFontSize(FontSizeOption fontSize) {
    _currentFontSize = fontSize;
  }

  // Универсальный метод для получения размера шрифта
  static double getFontSize({
    required double large,
    required double medium,
    required double small,
  }) {
    switch (_currentFontSize) {
      case FontSizeOption.small:
        return small;
      case FontSizeOption.medium:
        return medium;
      case FontSizeOption.large:
        return large;
    }
  }

  // Предустановленные размеры для разных типов текста

  // Заголовки, названия экранов и форм (24/28/20)
  static double getHeadlineFontSize() {
    return getFontSize(large: 28, medium: 24, small: 20);
  }

  // Описания и подзаголовки (16/18/14)
  static double getSubtitleFontSize() {
    return getFontSize(large: 18, medium: 16, small: 14);
  }

  // Более мелкие описания, тексты в кнопках (14/16/12)
  static double getBodyFontSize() {
    return getFontSize(large: 16, medium: 14, small: 12);
  }

  // Наименьшие описания, для маленьких формочек и текст внутри графиков (12/14/10)
  static double getCaptionFontSize() {
    return getFontSize(large: 14, medium: 12, small: 10);
  }

  // Темная тема (текущая)
  static ThemeData darkTheme() => ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          elevation: 0,
        ),
        cardColor: Colors.grey[900],
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.amber),
          trackColor: MaterialStateProperty.all(Colors.grey[800]),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.amber,
          inactiveTrackColor: Colors.grey[600],
          thumbColor: Colors.amber,
          overlayColor: Colors.amber.withOpacity(0.2),
          valueIndicatorColor: Colors.amber,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: Colors.amber, 
            fontWeight: FontWeight.bold,
            fontSize: getHeadlineFontSize(),
          ),
          titleLarge: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: getSubtitleFontSize(),
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: getBodyFontSize(),
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: getBodyFontSize(),
          ),
        ),
      );

  // Светлая тема (новая)
  static ThemeData lightTheme() => ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.cyan,
          elevation: 0,
        ),
        cardColor: Colors.grey[100],
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.cyan),
          trackColor: MaterialStateProperty.all(Colors.grey[400]),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.cyan,
          inactiveTrackColor: Colors.grey[400],
          thumbColor: Colors.cyan,
          overlayColor: Colors.cyan.withOpacity(0.2),
          valueIndicatorColor: Colors.cyan,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyan),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: Colors.cyan, 
            fontWeight: FontWeight.bold,
            fontSize: getHeadlineFontSize(),
          ),
          titleLarge: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: getSubtitleFontSize(),
          ),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: getBodyFontSize(),
          ),
          bodyMedium: TextStyle(
            color: Colors.black87,
            fontSize: getBodyFontSize(),
          ),
        ),
      );

  // Цвета для виджетов
  static Color getPrimaryColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.cyan;

  static Color getIconColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.white;
      
  static Color getBackgroundColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white;
      
  static Color getTextColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
      
  static Color getSecondaryTextColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  // Дополнительные методы для удобства получения размеров шрифта
  static double getSmallFontSize() => getCaptionFontSize();
  static double getNormalFontSize() => getBodyFontSize();
  static double getLargeFontSize() => getSubtitleFontSize();
  static double getTitleFontSize() => getHeadlineFontSize();

  // Метод для получения текущего размера шрифта (для настроек)
  static FontSizeOption getCurrentFontSize() => _currentFontSize;
}