import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/planets/data/models/planets_model.dart';
import 'package:flutter_ar/features/planets/presentation/home_page.dart';
import 'package:flutter_ar/features/prediction/presentation/prediction_page.dart';
import 'package:flutter_ar/features/simulation/presentation/simulation_page.dart';
import 'package:flutter_ar/features/overlay/ai/presentation/ai_overlay.dart';

class AINavigation {
  static Widget? getDestination(
    String? navigation,
    List<PlanetsModel> planets,
    Function(bool) onThemeChanged,
    bool isDarkTheme,
    Function(FontSizeOption) onFontSizeChanged,
    FontSizeOption fontSize,
  ) {
    switch (navigation) {
      case 'Mercury':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Меркурий'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Venus':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Венера'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Earth':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Земля'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Mars':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Марс'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Jupiter':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Юпитер'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Saturn':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Сатурн'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Uranus':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Уран'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Neptune':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Нептун'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Pluto':
        return HomePage(
          initialPlanetIndex: planets.indexWhere((p) => p.name == 'Плутон'),
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      case 'Simulation':
        return const SimulationPage(); 
      case 'Prediction':
        return PredictionPage(
          onThemeChanged: onThemeChanged,
          isDarkTheme: isDarkTheme,
          onFontSizeChanged: onFontSizeChanged,
          fontSize: fontSize,
        );
      default:
        return null;
    }
  }

  static Future<void> navigate(BuildContext context, Widget destination) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIOverlay(
          child: destination,
          onThemeChanged: (bool value) {},
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
          onFontSizeChanged: (FontSizeOption value) {},
          fontSize: FontSizeOption.medium,
        ),
      ),
    );
  }
}