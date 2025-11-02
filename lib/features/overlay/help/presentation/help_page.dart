import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/help/data/help_data.dart';
import 'package:flutter_ar/features/overlay/help/presentation/help_topic_page.dart';
import 'package:flutter_ar/features/overlay/help/presentation/widgets/help_small_tile.dart';
import 'package:flutter_ar/features/overlay/help/presentation/widgets/help_tile.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          'Справочник',
          style: TextStyle(
            color: AppTheme.getPrimaryColor(context),
            fontSize: AppTheme.getHeadlineFontSize(),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.getSecondaryTextColor(context).withOpacity(0.3),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: helpMainItems.length,
            itemBuilder: (context, index) {
              final item = helpMainItems[index];
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
          const SizedBox(height: 32),
          ...helpSmallItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: HelpSmallTile(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HelpTopicPage(
                          title: item.label,
                          questions: helpQuestions[item.label] ?? [],
                        ),
                      ),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}