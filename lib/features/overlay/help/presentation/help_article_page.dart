import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/help/presentation/widgets/feedback_widget.dart';

class HelpArticlePage extends StatefulWidget {
  final String question;
  final String answer;

  const HelpArticlePage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<HelpArticlePage> createState() => _HelpArticlePageState();
}

class _HelpArticlePageState extends State<HelpArticlePage> {
  bool _showFeedback = true;
  bool _rated = false;

  void _onRate(bool useful) {
    setState(() {
      _showFeedback = false;
      _rated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Вопрос',
          style: TextStyle(
            color: AppTheme.getPrimaryColor(context),
            fontSize: AppTheme.getHeadlineFontSize(),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.question,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: AppTheme.getLargeFontSize(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.answer,
            style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context),
              fontSize: AppTheme.getBodyFontSize(),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Обратная связь
          if (_showFeedback)
            FeedbackWidget(onRate: _onRate)
          else if (_rated)
            Center(
              child: Column(
                children: [
                  Text(
                    'Спасибо за оценку.',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: AppTheme.getNormalFontSize(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Мы всегда рады вам помочь!',
                    style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}