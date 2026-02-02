import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/auth_provider.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/presentation/user/screens/my_questions_screen.dart';
import 'package:flutter_ar/features/overlay/help/presentation/help_page.dart';
import 'package:flutter_ar/features/overlay/settings/dialog/app_version_dialog.dart';
import 'package:flutter_ar/features/overlay/settings/dialog/developer_dialog.dart';
import 'package:flutter_ar/features/overlay/settings/dialog/feedback_dialog.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/action_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/ai_model_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/cache_clear_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/font_size_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/info_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/slider_setting.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/widgets/switch_setting.dart';
import 'package:provider/provider.dart';

class SettingsList extends StatelessWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;
  final FontSizeOption fontSize;
  final ValueChanged<FontSizeOption> onFontSizeChanged;
  final bool isAnimationEnabled;
  final ValueChanged<bool> onAnimationEnabledChanged;
  final bool isAutoSpeakEnabled;
  final ValueChanged<bool> onAutoSpeakEnabledChanged;
  final double ttsSpeed;
  final ValueChanged<double> onTtsSpeedChanged;
  final AIModel aiModel;
  final ValueChanged<AIModel> onAIModelChanged;
  final int cacheSize;
  final bool isClearingCache;
  final VoidCallback onClearCache;
  final Map<String, Color> theme;

  const SettingsList({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.isAnimationEnabled,
    required this.onAnimationEnabledChanged,
    required this.isAutoSpeakEnabled,
    required this.onAutoSpeakEnabledChanged,
    required this.ttsSpeed,
    required this.onTtsSpeedChanged,
    required this.aiModel,
    required this.onAIModelChanged,
    required this.cacheSize,
    required this.isClearingCache,
    required this.onClearCache,
    required this.theme,
  });

  Color get _cardColor => isDarkTheme
      ? Colors.grey[900]!
      : theme['primary']!.withOpacity(0.2).withAlpha(180);

  Color get _alertColor => isDarkTheme 
      ? Colors.black 
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section('Общие'),
        SwitchSetting(
          title: 'Тёмная тема',
          subtitle: 'Переключить тему приложения',
          value: isDarkTheme,
          onChanged: onThemeChanged,
          theme: theme,
          cardColor: _cardColor,
        ),
        FontSizeSetting(
          value: fontSize,
          onChanged: onFontSizeChanged,
          theme: theme,
          cardColor: _cardColor,
        ),
        SwitchSetting(
          title: 'Анимации',
          subtitle: 'Включить анимации в приложении',
          value: isAnimationEnabled,
          onChanged: onAnimationEnabledChanged,
          theme: theme,
          cardColor: _cardColor,
        ),
        const SizedBox(height: 24),

        _section('Голосовой помощник'),
        SwitchSetting(
          title: 'Автопроизношение',
          subtitle: 'Автоматически озвучивать ответы ИИ',
          value: isAutoSpeakEnabled,
          onChanged: onAutoSpeakEnabledChanged,
          theme: theme,
          cardColor: _cardColor,
        ),
        SliderSetting(
          value: ttsSpeed,
          onChanged: onTtsSpeedChanged,
          theme: theme,
          cardColor: _cardColor,
        ),
        AIModelSetting(
          value: aiModel,
          onChanged: onAIModelChanged,
          theme: theme,
          cardColor: _cardColor,
          context: context,
        ),
        const SizedBox(height: 24),

        _section('О приложении'),
        InfoSetting(
          title: 'Версия приложения',
          subtitle: '0.9.0',
          theme: theme,
          cardColor: _cardColor,
          onTap: () => showAppVersionDialog(context, theme, _alertColor),
        ),
        InfoSetting(
          title: 'Разработчик',
          subtitle: 'VladPomian',
          theme: theme,
          cardColor: _cardColor,
          onTap: () => showDeveloperDialog(context, theme, _alertColor),
        ),
        CacheClearSetting(
          cacheSize: cacheSize,
          isLoading: isClearingCache,
          onClear: onClearCache,
          theme: theme,
          cardColor: _cardColor,
        ),
        const SizedBox(height: 24),

        _section('Поддержка'),
        ActionSetting(
          title: 'Обратная связь',
          subtitle: 'Отправить сообщение разработчикам',
          icon: Icons.feedback,
          onTap: () {
            final auth = context.read<AuthProvider>();
            if (auth.isAuthenticated) {
              showFeedbackDialog(context, theme, _alertColor);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Необходимо войти в аккаунт')),
              );
            }
          },
          theme: theme,
          cardColor: _cardColor,
        ),

        ActionSetting(
          title: 'Мои сообщения',
          subtitle: 'История обращений и ответы',
          icon: Icons.question_answer,
          onTap: () {
            if (context.read<AuthProvider>().isAuthenticated && 
                !context.read<AuthProvider>().isAdmin) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyQuestionsScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Доступно только авторизованным пользователям')),
              );
            }
          },
          theme: theme,
          cardColor: _cardColor,
        ),
        ActionSetting(
          title: 'Помощь',
          subtitle: 'Руководство по использованию',
          icon: Icons.help_outline,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          ),
          theme: theme,
          cardColor: _cardColor,
        ),
        ActionSetting(
          title: 'Выйти из аккаунта',
          subtitle: 'Завершить сессию',
          icon: Icons.logout,
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Выйти из аккаунта'),
                content: const Text('Завершить работу в аккаунте и вернуться на экран входа?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Выйти', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await context.read<AuthProvider>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            }
          },
          theme: theme,
          cardColor: _cardColor,
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            color: theme['primary'],
            fontSize: AppTheme.getHeadlineFontSize(),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}