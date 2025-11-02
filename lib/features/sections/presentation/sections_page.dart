import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/ai/presentation/ai_overlay.dart';
import 'package:flutter_ar/features/planets/presentation/home_page.dart';
import 'package:flutter_ar/features/prediction/presentation/prediction_page.dart';
import 'package:flutter_ar/features/simulation/presentation/simulation_page.dart';
import 'package:flutter_ar/features/start/presentation/widgets/background_widget.dart';
import 'package:provider/provider.dart';
import 'models/sections_model.dart';
import 'widgets/card_stack.dart';
import 'animations/pulse_animation.dart';

class SectionsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const SectionsPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> with SingleTickerProviderStateMixin {
  late List<Section> sections;
  late PulseAnimation pulseAnimation;
  List<int> order = [0, 1, 2];
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    pulseAnimation = PulseAnimation(vsync: this);
    if (_settingsProvider.isAnimationEnabled) {
      pulseAnimation.controller.forward();
    }
    _updateSections();
    _settingsProvider.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (_settingsProvider.isAnimationEnabled) {
      if (!pulseAnimation.controller.isAnimating) {
        pulseAnimation.controller.forward();
      }
    } else {
      if (pulseAnimation.controller.isAnimating) {
        pulseAnimation.controller.stop();
      }
    }
  }

  void _updateSections() {
    sections = [
      Section(
        icon: Icons.public,
        title: 'Исследование планет',
        description: 'Погрузитесь в мир планет!',
        descriptionSecond: 'Изучайте их особенности и открывайте космос в дополненной реальности.',
        destination: HomePage(
          onFontSizeChanged: widget.onFontSizeChanged,
          fontSize: widget.fontSize,
        ),
      ),
      Section(
        icon: Icons.timeline,
        title: 'Предсказание явлений',
        description: 'Узнайте, что ждёт космос!',
        descriptionSecond: 'Яркие графики и прогнозы солнечных бурь и вспышек.',
        destination: PredictionPage(
          onThemeChanged: widget.onThemeChanged,
          isDarkTheme: widget.isDarkTheme,
          onFontSizeChanged: widget.onFontSizeChanged,
          fontSize: widget.fontSize,
        ),
      ),
      Section(
        icon: Icons.threed_rotation,
        title: 'Симуляция',
        description: 'Путешествуйте по Солнечной системе!',
        descriptionSecond: 'Исследуйте планеты в захватывающей 3D-симуляции.',
        destination: const SimulationPage(),
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _updateSections();
    });
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    pulseAnimation.dispose();
    super.dispose();
  }

  void rotateUp() {
    setState(() {
      order = [order[1], order[2], order[0]];
      if (_settingsProvider.isAnimationEnabled) {
        pulseAnimation.controller.reset();
        pulseAnimation.controller.forward();
      }
    });
  }

  void rotateDown() {
    setState(() {
      order = [order[2], order[0], order[1]];
      if (_settingsProvider.isAnimationEnabled) {
        pulseAnimation.controller.reset();
        pulseAnimation.controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDarkTheme = _settingsProvider.isDarkTheme;

    return AIOverlay(
      onThemeChanged: _settingsProvider.setTheme,
      isDarkTheme: currentDarkTheme,
      onFontSizeChanged: _settingsProvider.setFontSize,
      fontSize: _settingsProvider.fontSize,
      child: Scaffold(
        body: Stack(
          children: [
            BackgroundWidget(isDarkTheme: currentDarkTheme),
            SafeArea(
              child: CardStack(
                sections: sections,
                order: order,
                pulseAnimation: pulseAnimation,
                onRotateUp: rotateUp,
                onRotateDown: rotateDown,
                isDarkTheme: currentDarkTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}