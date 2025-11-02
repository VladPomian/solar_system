import 'package:flutter/material.dart';

class ErrorSnackBar {
  static void show(BuildContext context, String errorCode, GlobalKey aiIconKey) {
    String errorMessage;
    switch (errorCode) {
      case '503':
        errorMessage = 'Ошибка ИИ: Нет интернета. Проверьте подключение.';
        break;
      case '401':
        errorMessage = 'Ошибка ИИ: Неверный ключ API. Обратитесь в поддержку.';
        break;
      case '500':
        errorMessage = 'Ошибка ИИ: Ошибка обработки ответа. Попробуйте позже.';
        break;
      case '900':
        errorMessage = 'Ошибка ИИ: Не удалось открыть ссылку.';
        break;
      case 'speech_error':
        errorMessage = 'Ошибка распознавания речи. Попробуйте снова.';
        break;
      case 'speech_init_error':
        errorMessage = 'Не удалось инициализировать распознавание речи.';
        break;
      case 'tts_error':
        errorMessage = 'Ошибка озвучивания текста. Попробуйте снова.';
        break;
      default:
        errorMessage = 'Ошибка ИИ: Код $errorCode. Попробуйте позже.';
    }

    AnimationController? snackBarAnimationController;
    OverlayEntry? snackBarOverlayEntry;

    snackBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: snackBarAnimationController,
      curve: Curves.easeOut,
    ));

    final snackBarWidget = Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                snackBarAnimationController?.reverse().then((_) {
                  snackBarOverlayEntry?.remove();
                  snackBarOverlayEntry = null;
                });
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );

    final RenderBox? renderBox = aiIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      snackBarOverlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: position.dy + renderBox.size.height + 8,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: SlideTransition(
            position: slideAnimation,
            child: snackBarWidget,
          ),
        ),
      );
      Overlay.of(context).insert(snackBarOverlayEntry!);
      snackBarAnimationController.forward();
      Future.delayed(const Duration(seconds: 10), () {
        if (snackBarOverlayEntry != null) {
          snackBarAnimationController?.reverse().then((_) {
            snackBarOverlayEntry?.remove();
            snackBarOverlayEntry = null;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[900],
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}