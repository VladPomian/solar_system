import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/cache_service.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/settings_list.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkTheme;
  final FontSizeOption fontSize;
  final bool isAnimationEnabled;
  final bool isAutoSpeakEnabled;
  final double ttsSpeed;
  final AIModel aiModel;

  final Function(bool) onThemeChanged;
  final Function(FontSizeOption) onFontSizeChanged;
  final Function(bool) onAnimationEnabledChanged;
  final Function(bool) onAutoSpeakEnabledChanged;
  final Function(double) onTtsSpeedChanged;
  final Function(AIModel) onAIModelChanged;

  const SettingsPage({
    super.key,
    required this.isDarkTheme,
    required this.fontSize,
    required this.isAnimationEnabled,
    required this.isAutoSpeakEnabled,
    required this.ttsSpeed,
    required this.aiModel,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onAnimationEnabledChanged,
    required this.onAutoSpeakEnabledChanged,
    required this.onTtsSpeedChanged,
    required this.onAIModelChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkTheme;
  late FontSizeOption _fontSize;
  late bool _isAnimationEnabled;
  late bool _isAutoSpeakEnabled;
  late double _ttsSpeed;
  late AIModel _aiModel;

  int _cacheSize = 0;
  bool _isClearingCache = false;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
    _fontSize = widget.fontSize;
    _isAnimationEnabled = widget.isAnimationEnabled;
    _isAutoSpeakEnabled = widget.isAutoSpeakEnabled;
    _ttsSpeed = widget.ttsSpeed;
    _aiModel = widget.aiModel;
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await CacheService().getCacheSize();
    if (mounted) {
      setState(() => _cacheSize = size);
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Очистить кэш?'),
        content: Text('Будут удалены временные файлы (${CacheService.formatSize(_cacheSize)}).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearingCache = true);

    await CacheService().clearCache();
    await _loadCacheSize();

    setState(() => _isClearingCache = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Кэш очищен')),
      );
    }
  }

  void _onThemeChanged(bool value) {
    setState(() => _isDarkTheme = value);
    widget.onThemeChanged(value);
  }

  void _onFontSizeChanged(FontSizeOption value) {
    setState(() => _fontSize = value);
    widget.onFontSizeChanged(value);
  }

  void _onAnimationChanged(bool value) {
    setState(() => _isAnimationEnabled = value);
    widget.onAnimationEnabledChanged(value);
  }

  void _onAutoSpeakChanged(bool value) {
    setState(() => _isAutoSpeakEnabled = value);
    widget.onAutoSpeakEnabledChanged(value);
  }

  void _onTtsSpeedChanged(double value) {
    setState(() => _ttsSpeed = value);
    widget.onTtsSpeedChanged(value);
  }

  void _onAIModelChanged(AIModel value) {
    setState(() => _aiModel = value);
    widget.onAIModelChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = {
      'text': AppTheme.getTextColor(context),
      'primary': AppTheme.getPrimaryColor(context),
      'icon': AppTheme.getIconColor(context),
      'background': AppTheme.getBackgroundColor(context),
      'secondary': AppTheme.getSecondaryTextColor(context),
    };

    return Scaffold(
      backgroundColor: theme['background'],
      appBar: AppBar(
        title: Text('Настройки',
            style: TextStyle(
              color: theme['primary'],
              fontSize: AppTheme.getHeadlineFontSize(),
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: theme['background'],
        elevation: 0,
        iconTheme: IconThemeData(color: theme['primary']),
      ),
      body: SettingsList(
        isDarkTheme: _isDarkTheme,
        onThemeChanged: _onThemeChanged,
        fontSize: _fontSize,
        onFontSizeChanged: _onFontSizeChanged,
        isAnimationEnabled: _isAnimationEnabled,
        onAnimationEnabledChanged: _onAnimationChanged,
        isAutoSpeakEnabled: _isAutoSpeakEnabled,
        onAutoSpeakEnabledChanged: _onAutoSpeakChanged,
        ttsSpeed: _ttsSpeed,
        onTtsSpeedChanged: _onTtsSpeedChanged,
        aiModel: _aiModel,
        onAIModelChanged: _onAIModelChanged,
        cacheSize: _cacheSize,
        isClearingCache: _isClearingCache,
        onClearCache: _clearCache,
        theme: theme,
      ),
    );
  }
}