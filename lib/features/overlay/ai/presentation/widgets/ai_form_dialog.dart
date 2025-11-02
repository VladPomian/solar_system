import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/ai/domain/services/speech_service.dart';
import 'package:flutter_ar/features/overlay/ai/domain/services/tts_service.dart';

class AIFormDialog {
  static void show({
    required BuildContext context,
    required SpeechService speechService,
    required Function(String) onSubmit,
    required TtsService ttsService,
    required TickerProvider vsync,
    required Function(String) onSpeechError,
    required Function(String) onSpeechStatus,
    required bool isDarkTheme,
    required FontSizeOption fontSize,
  }) {
    final controller = TextEditingController();
    bool isListening = false;

    final waveController1 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
    final waveController2 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
    final waveController3 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    final waveAnimation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: waveController1, curve: Curves.easeOut),
    );
    final waveAnimation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: waveController2, curve: Curves.easeOut),
    );
    final waveAnimation3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: waveController3, curve: Curves.easeOut),
    );

    void startWaveAnimation() {
      waveController1.repeat();
      Future.delayed(const Duration(milliseconds: 200), () {
        waveController2.repeat();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        waveController3.repeat();
      });
    }

    void stopWaveAnimation() {
      waveController1.stop();
      waveController2.stop();
      waveController3.stop();
      waveController1.reset();
      waveController2.reset();
      waveController3.reset();
    }

    void disposeControllers() {
      waveController1.dispose();
      waveController2.dispose();
      waveController3.dispose();
      ttsService.stop();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            isListening = speechService.isListening;
            if (isListening) {
              startWaveAnimation();
            } else {
              stopWaveAnimation();
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 280,
                maxWidth: 350, // Оставляем 350 для дополнительного пространства
                minHeight: 200,
                maxHeight: 250,
              ),
              child: AlertDialog(
                title: Text(
                  'Запрос к ИИ',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: AppTheme.getHeadlineFontSize(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppTheme.getBackgroundColor(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 120,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.getPrimaryColor(context),
                          AppTheme.getBackgroundColor(context),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: AppTheme.getBodyFontSize(),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Введите запрос',
                            labelStyle: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: AppTheme.getCaptionFontSize(),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.getPrimaryColor(context),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.getPrimaryColor(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.getPrimaryColor(context),
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: isListening ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Visibility(
                                visible: !isListening,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.getSecondaryTextColor(context),
                                  ),
                                  onPressed: () {
                                    controller.clear();
                                    speechService.stop();
                                    disposeControllers();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Отменить',
                                    style: TextStyle(
                                      fontSize: AppTheme.getBodyFontSize(),
                                      color: AppTheme.getSecondaryTextColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            opacity: isListening ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Visibility(
                              visible: !isListening,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: SizedBox(
                                width: 140, // Фиксированная ширина для кнопки
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.getPrimaryColor(context),
                                    foregroundColor: AppTheme.getTextColor(context),
                                    minimumSize: const Size(0, 36), // Высота 36
                                  ),
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      onSubmit(controller.text);
                                      controller.clear();
                                      speechService.stop();
                                      disposeControllers();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text(
                                    'Отправить',
                                    style: TextStyle(
                                      fontSize: AppTheme.getBodyFontSize(),
                                      color: AppTheme.getTextColor(context),
                                    ),
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: isListening
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                if (isListening) ...[
                                  AnimatedBuilder(
                                    animation: waveAnimation1,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: 1 - waveAnimation1.value,
                                        child: Container(
                                          width: 50 * waveAnimation1.value + 30,
                                          height: 50 * waveAnimation1.value + 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: waveAnimation2,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: 1 - waveAnimation2.value,
                                        child: Container(
                                          width: 60 * waveAnimation2.value + 30,
                                          height: 60 * waveAnimation2.value + 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: waveAnimation3,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: 1 - waveAnimation3.value,
                                        child: Container(
                                          width: 70 * waveAnimation3.value + 30,
                                          height: 70 * waveAnimation3.value + 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                IconButton(
                                  icon: Icon(
                                    isListening ? Icons.mic : Icons.mic_none,
                                    color: isListening
                                        ? AppTheme.getPrimaryColor(context)
                                        : AppTheme.getTextColor(context),
                                    size: isListening ? 36 : 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  onPressed: () async {
                                    if (!isListening) {
                                      bool available = await speechService.initialize(
                                        onStatus: (status) {
                                          onSpeechStatus(status);
                                        },
                                        onError: (error) {
                                          setState(() {
                                            isListening = false;
                                            controller.text = 'Ошибка распознавания речи';
                                          });
                                          onSpeechError('speech_error');
                                        },
                                      );
                                      if (available) {
                                        setState(() {
                                          isListening = true;
                                          controller.text = 'Начата запись';
                                        });
                                        speechService.listen(
                                          onResult: (text) {
                                            setState(() {
                                              controller.text = text;
                                            });
                                          },
                                          localeId: 'ru_RU',
                                        );
                                      } else {
                                        onSpeechError('speech_init_error');
                                      }
                                    } else {
                                      await speechService.stop();
                                      setState(() {
                                        isListening = false;
                                        controller.text = controller.text.isEmpty ||
                                                controller.text == 'Начата запись'
                                            ? ''
                                            : controller.text;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (!isListening) const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}