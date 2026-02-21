import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';

void showFeedbackDialog(BuildContext parentContext, Map<String, Color> theme, Color alertColor) {
final uid = FirebaseAuth.instance.currentUser?.uid;
final firestoreService = FirestoreService(currentUid: uid);

  showDialog(
    context: parentContext,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _FeedbackDialogContent(
        parentContext: parentContext,
        theme: theme,
        alertColor: alertColor,
        firestoreService: firestoreService,
      );
    },
  );
}

class _FeedbackDialogContent extends StatefulWidget {
  final BuildContext parentContext;
  final Map<String, Color> theme;
  final Color alertColor;
  final FirestoreService firestoreService;

  const _FeedbackDialogContent({
    required this.parentContext,
    required this.theme,
    required this.alertColor,
    required this.firestoreService,
  });

  @override
  State<_FeedbackDialogContent> createState() => _FeedbackDialogContentState();
}

class _FeedbackDialogContentState extends State<_FeedbackDialogContent> {
  late final TextEditingController themeController;
  late final TextEditingController messageController;

  bool isLoading = false;
  String? errorMessage;

  static const int maxThemeLength = 20;
  static const int maxMessageLength = 500;

  @override
  void initState() {
    super.initState();
    themeController = TextEditingController();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    themeController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.alertColor,
      title: Text(
        'Обратная связь',
        style: TextStyle(
          color: widget.theme['text'],
          fontSize: AppTheme.getHeadlineFontSize(),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  TextField(
                    controller: themeController,
                    enabled: !isLoading,
                    maxLength: maxThemeLength,
                    decoration: InputDecoration(
                      labelText: 'Тема',
                      labelStyle: TextStyle(color: widget.theme['secondary']),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.theme['primary']!),
                      ),
                      counterText: '',
                    ),
                    style: TextStyle(color: widget.theme['text']),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: themeController,
                      builder: (context, value, _) {
                        final length = value.text.length;
                        if (length == 0) return const SizedBox.shrink();
                        return Text(
                          '$length/$maxThemeLength',
                          style: TextStyle(
                            fontSize: 11,
                            color: length > maxThemeLength * 0.9 
                                ? Colors.red 
                                : AppTheme.getSecondaryTextColor(context),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Stack(
                children: [
                  TextField(
                    controller: messageController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: maxMessageLength,
                    decoration: InputDecoration(
                      labelText: 'Сообщение',
                      labelStyle: TextStyle(color: widget.theme['secondary']),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.theme['primary']!),
                      ),
                      alignLabelWithHint: true,
                      counterText: '',
                    ),
                    style: TextStyle(color: widget.theme['text']),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: messageController,
                      builder: (context, value, _) {
                        final length = value.text.length;
                        if (length == 0) return const SizedBox.shrink();
                        return Text(
                          '$length/$maxMessageLength',
                          style: TextStyle(
                            fontSize: 11,
                            color: length > maxMessageLength * 0.9 
                                ? Colors.red 
                                : AppTheme.getSecondaryTextColor(context),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              if (isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text('Отмена', style: TextStyle(color: widget.theme['primary'])),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submitFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme['primary'],
          ),
          child: const Text('Отправить', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submitFeedback() async {
    final themeText = themeController.text.trim();
    final messageText = messageController.text.trim();

    if (themeText.isEmpty || messageText.isEmpty) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    if (themeText.length > maxThemeLength || messageText.length > maxMessageLength) {
      setState(() {
        errorMessage = 'Превышено ограничение по символам';
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      await widget.firestoreService.createTicket(themeText, messageText).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Время ожидания истекло');
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(
            content: Text('Обращение отправлено!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          errorMessage = 'Время ожидания истекло. Возможно, превышена квота Firestore.';
          isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      String userMessage = 'Ошибка отправки';

      switch (e.code) {
        case 'resource-exhausted':
        case 'quota-exceeded':
          userMessage = 'Превышен лимит обращений (квота Firestore). Попробуйте позже.';
          break;
        case 'permission-denied':
          userMessage = 'Нет прав на отправку.';
          break;
        case 'unavailable':
        case 'deadline-exceeded':
          userMessage = 'Сервис временно недоступен.';
          break;
        default:
          userMessage = 'Ошибка: ${e.message ?? e.code}';
          debugPrint('Firestore error: ${e.code} — ${e.message}');
      }

      if (mounted) {
        setState(() {
          errorMessage = userMessage;
          isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Неожиданная ошибка при отправке: $e\n$stack');

      if (mounted) {
        setState(() {
          errorMessage = 'Не удалось отправить. Возможно, превышена квота или проблема с сетью.';
          isLoading = false;
        });
      }
    }
  }
}