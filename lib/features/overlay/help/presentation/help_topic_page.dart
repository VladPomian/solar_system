import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/help/data/help_data.dart';
import 'package:flutter_ar/features/overlay/help/data/help_models.dart';
import 'package:flutter_ar/features/overlay/help/presentation/help_article_page.dart';
import 'package:flutter_ar/features/overlay/help/presentation/widgets/help_tile.dart';

class HelpTopicPage extends StatelessWidget {
  final String title;
  final List<HelpLargeItem> largeItems;
  final List<HelpQuestionItem> questions;

  const HelpTopicPage({
    super.key,
    required this.title,
    this.largeItems = const [],
    this.questions = const [],
  });

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
          title,
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
          if (largeItems.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: largeItems.length,
              itemBuilder: (context, index) {
                final item = largeItems[index];
                return HelpTile(
                  icon: item.icon,
                  label: item.label,
                  gradient: item.gradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HelpTopicPage(
                          title: item.label,
                          largeItems: helpSubItems[item.label] ?? [],
                          questions: helpQuestions[item.label] ?? [],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          if (questions.isNotEmpty) ...[
            if (largeItems.isNotEmpty) ...[
              Text(
                'Общие вопросы',
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontSize: AppTheme.getLargeFontSize(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...questions.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HelpArticlePage(
                          question: q.question,
                          answer: q.answer,
                        ),
                      ),
                    ),
                    child: Text(
                      q.question,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: AppTheme.getBodyFontSize(),
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}