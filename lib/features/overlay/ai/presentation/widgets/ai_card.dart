import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/core/utils/url_validator.dart';
import 'package:flutter_ar/features/overlay/ai/data/models/ai_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ACard extends StatelessWidget {
  final AIState state;
  final Animation<Offset> animation;
  final VoidCallback onHide;
  final bool isDarkTheme;
  final FontSizeOption fontSize;

  const ACard({
    super.key,
    required this.state,
    required this.animation,
    required this.onHide,
    required this.isDarkTheme,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 72 + 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: ClipRect(
          child: SlideTransition(
            position: animation,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ClipRect(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: (MediaQuery.of(context).size.height * 0.3 - 56),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context).withOpacity(0.8),
                    border: Border.all(
                      color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(
                                  state.aiContent!,
                                  style: TextStyle(
                                    fontSize: AppTheme.getBodyFontSize(),
                                    color: AppTheme.getTextColor(context),
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              if (state.aiLink != null && state.aiLink!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                SizedBox(
                                  height: 24,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.getPrimaryColor(context),
                                      foregroundColor: AppTheme.getTextColor(context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final validatedUrl = UrlValidator.validateUrl(state.aiLink!);
                                      final uri = Uri.parse(validatedUrl);
                                      final canLaunch = await canLaunchUrl(uri);
                                      if (canLaunch) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Не удалось открыть ссылку',
                                              style: TextStyle(
                                                fontSize: AppTheme.getBodyFontSize(),
                                                color: AppTheme.getTextColor(context),
                                              ),
                                            ),
                                            backgroundColor: AppTheme.getBackgroundColor(context).withOpacity(0.9),
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Ресурс',
                                      style: TextStyle(
                                        fontSize: AppTheme.getBodyFontSize(),
                                        color: AppTheme.getTextColor(context),
                                      ),
                                      softWrap: false,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            foregroundColor: AppTheme.getTextColor(context),
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: onHide,
                          child: const Icon(
                            Icons.chevron_right,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}