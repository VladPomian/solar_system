import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';

void showFeedbackDialog(BuildContext parentContext, Map<String, Color> theme, Color alertColor) {
final uid = FirebaseAuth.instance.currentUser?.uid;
final firestoreService = FirestoreService(currentUid: uid);

  showDialog(
    context: parentContext,
    barrierDismissible: false,
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
                    TextField(
                      controller: themeController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Тема',
                        labelStyle: TextStyle(color: widget.theme['secondary']),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.theme['primary']!),
                        ),
                      ),
                      style: TextStyle(color: widget.theme['text']),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      enabled: !isLoading,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Сообщение',
                        labelStyle: TextStyle(color: widget.theme['secondary']),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.theme['primary']!),
                        ),
                      ),
                      style: TextStyle(color: widget.theme['text']),
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
          onPressed: isLoading
              ? null
              : () async {
                  final themeText = themeController.text.trim();
                  final messageText = messageController.text.trim();

                  if (themeText.isEmpty || messageText.isEmpty) {
                    if (widget.parentContext.mounted) {
                      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля')),
                      );
                    }
                    return;
                  }

                  setState(() {
                    errorMessage = null;
                    isLoading = true;
                  });

                  try {
                    await widget.firestoreService.createTicket(themeText, messageText);

                    if (widget.parentContext.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Обращение отправлено! ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Ошибка отправки обратной связи: $e');
                    if (mounted) {
                      setState(() {
                        errorMessage = 'Не удалось отправить. Проверьте интернет.';
                        isLoading = false;
                      });
                    }
                  }
                },
          child: const Text('Отправить', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme['primary'],
          ),
        ),
      ],
    );
  }
}