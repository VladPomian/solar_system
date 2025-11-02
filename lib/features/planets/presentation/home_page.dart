import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/planets/data/models/planets_model.dart';
import 'package:flutter_ar/features/planets/presentation/planet_page.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';

class HomePage extends StatelessWidget {
  final int initialPlanetIndex;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const HomePage({
    super.key,
    this.initialPlanetIndex = 0,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final pages = planets.map((planet) {
      return PlanetPage(
        planet: planet,
        fontSize: settings.fontSize,
      );
    }).toList();
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages,
            fullTransitionValue: 600,
            enableLoop: true,
            waveType: WaveType.liquidReveal,
            enableSideReveal: true,
            slideIconWidget: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.getTextColor(context),
            ),
            initialPage: initialPlanetIndex,
          ),
        ],
      ),
    );
  }
}