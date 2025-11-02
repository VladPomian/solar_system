import 'package:flutter/material.dart';
import '../presentation/widgets/clickable_link.dart';

void showDeveloperDialog(BuildContext context, Map<String, Color> theme, Color alertColor) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: alertColor,
      title: Text('Разработчик', style: TextStyle(color: theme['text'])),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VladPomian', style: TextStyle(color: theme['text'], fontSize: 18)),
          const SizedBox(height: 8),
          Text('Flutter-разработчик', style: TextStyle(color: theme['secondary'])),
          Text('Специализация: AI, AR, TTS', style: TextStyle(color: theme['secondary'])),
          const SizedBox(height: 16),
          ClickableLink(
            icon: Icons.telegram,
            text: '@vladpomian',
            url: 'https://t.me/vladpomian',
            fallbackUrl: 'tg://resolve?domain=vladpomian',
            primaryColor: theme['primary']!,
            underline: false,
          ),
          const SizedBox(height: 12),
          ClickableLink(
            icon: Icons.code,
            text: 'github.com/VladPomian',
            url: 'https://github.com/VladPomian',
            primaryColor: theme['primary']!,
            underline: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Закрыть', style: TextStyle(color: theme['primary'])),
        ),
      ],
    ),
  );
}