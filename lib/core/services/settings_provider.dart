import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

enum AIModel {
  llama4Scout('llama-4-scout-17b-16e-instruct'),
  llama31_8b('llama3.1-8b'),
  llama33_70b('llama-3.3-70b'),
  gptOss('gpt-oss-120b'),
  qwen3_32b('qwen-3-32b'),
  qwen3_235bInstruct('qwen-3-235b-a22b-instruct-2507'),
  qwen3_235bThinking('qwen-3-235b-a22b-thinking-2507'),
  qwen3_480bCoder('qwen-3-coder-480b');

  final String modelId;
  const AIModel(this.modelId);

  String get displayName {
    switch (this) {
      case AIModel.llama4Scout:
        return 'Llama Scout';
      case AIModel.llama31_8b:
        return 'Llama 8B';
      case AIModel.llama33_70b:
        return 'Llama 70B';
      case AIModel.gptOss:
        return 'GPT OSS';
      case AIModel.qwen3_32b:
        return 'Qwen 32B';
      case AIModel.qwen3_235bInstruct:
        return 'Qwen 235B Instruct';
      case AIModel.qwen3_235bThinking:
        return 'Qwen 235B Thinking';
      case AIModel.qwen3_480bCoder:
        return 'Qwen 480B Coder';
    }
  }

  String get description {
    switch (this) {
      case AIModel.llama4Scout:
        return 'Быстрая и универсальная модель для повседневных вопросов и задач.';
      case AIModel.llama31_8b:
        return 'Компактная модель с хорошей скоростью и точностью для простых запросов.';
      case AIModel.llama33_70b:
        return 'Мощная модель для сложных вопросов, обеспечивающая высокую точность ответов.';
      case AIModel.gptOss:
        return 'Высокопроизводительная модель для широкого спектра задач с отличной точностью.';
      case AIModel.qwen3_32b:
        return 'Универсальная модель для различных вопросов, баланс между скоростью и точностью.';
      case AIModel.qwen3_235bInstruct:
        return 'Экспериментальная модель для глубоких инструкций, может быть медленнее (для тестирования).';
      case AIModel.qwen3_235bThinking:
        return 'Экспериментальная модель, оптимизированная для аналитических задач (для тестирования).';
      case AIModel.qwen3_480bCoder:
        return 'Экспериментальная модель для технических и программистских запросов (для тестирования).';
    }
  }
}

class SettingsProvider with ChangeNotifier {
  bool _isDarkTheme = true;
  FontSizeOption _fontSize = FontSizeOption.medium;
  bool _isAnimationEnabled = true;
  bool _isAutoSpeakEnabled = true;
  double _ttsSpeed = 0.5;
  AIModel _aiModel = AIModel.llama31_8b;

  SettingsProvider() {
    _loadSettings();
  }

  bool get isDarkTheme => _isDarkTheme;
  FontSizeOption get fontSize => _fontSize;
  bool get isAnimationEnabled => _isAnimationEnabled;
  bool get isAutoSpeakEnabled => _isAutoSpeakEnabled;
  double get ttsSpeed => _ttsSpeed;
  AIModel get aiModel => _aiModel;

  void setTheme(bool isDark) {
    _isDarkTheme = isDark;
    _saveSettings();
    notifyListeners();
  }

  void setFontSize(FontSizeOption fontSize) {
    _fontSize = fontSize;
    AppTheme.setFontSize(fontSize);
    _saveSettings();
    notifyListeners();
  }

  void setAnimationEnabled(bool isEnabled) {
    _isAnimationEnabled = isEnabled;
    _saveSettings();
    notifyListeners();
  }

  void setAutoSpeakEnabled(bool isEnabled) {
    _isAutoSpeakEnabled = isEnabled;
    _saveSettings();
    notifyListeners();
  }

  void setTtsSpeed(double speed) {
    _ttsSpeed = speed;
    _saveSettings();
    notifyListeners();
  }

  void setAIModel(AIModel model) {
    _aiModel = model;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
    _isAnimationEnabled = prefs.getBool('isAnimationEnabled') ?? true;
    _isAutoSpeakEnabled = prefs.getBool('isAutoSpeakEnabled') ?? true;
    _ttsSpeed = prefs.getDouble('ttsSpeed') ?? 0.5;
    final aiModelString = prefs.getString('aiModel') ?? 'llama3.1-8b';
    _aiModel = AIModel.values.firstWhere(
      (e) => e.modelId == aiModelString,
      orElse: () => AIModel.llama31_8b,
    );
    final fontSizeString = prefs.getString('fontSize') ?? 'medium';
    _fontSize = FontSizeOption.values.firstWhere(
      (e) => e.toString() == 'FontSizeOption.$fontSizeString',
      orElse: () => FontSizeOption.medium,
    );
    AppTheme.setFontSize(_fontSize);
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setString('fontSize', _fontSize.toString().split('.').last);
    await prefs.setBool('isAnimationEnabled', _isAnimationEnabled);
    await prefs.setBool('isAutoSpeakEnabled', _isAutoSpeakEnabled);
    await prefs.setDouble('ttsSpeed', _ttsSpeed);
    await prefs.setString('aiModel', _aiModel.modelId);
  }
}