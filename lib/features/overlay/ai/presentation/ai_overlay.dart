import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/overlay/ai/data/models/ai_state.dart';
import 'package:flutter_ar/features/overlay/ai/domain/services/ai_service.dart';
import 'package:flutter_ar/features/overlay/ai/domain/services/speech_service.dart';
import 'package:flutter_ar/features/overlay/ai/domain/services/tts_service.dart';
import 'package:flutter_ar/features/overlay/ai/navigation/ai_navigation.dart';
import 'package:flutter_ar/features/overlay/ai/presentation/widgets/ai_card.dart';
import 'package:flutter_ar/features/overlay/ai/presentation/widgets/ai_form_dialog.dart';
import 'package:flutter_ar/features/overlay/ai/presentation/widgets/error_snack_bar.dart';
import 'package:flutter_ar/features/planets/data/models/planets_model.dart';
import 'package:flutter_ar/features/overlay/settings/presentation/settings_page.dart';
import 'package:provider/provider.dart';

class AIOverlay extends StatefulWidget {
  final Widget child;
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const AIOverlay({
    super.key,
    required this.child,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  State<AIOverlay> createState() => _AIOverlayState();
}

class _AIOverlayState extends State<AIOverlay> with TickerProviderStateMixin {
  static final ValueNotifier<AIState> _stateNotifier = ValueNotifier(AIState());
  static Timer? _hideTimer;

  final _aiService = AIService();
  final _speechService = SpeechService();
  final _ttsService = TtsService();
  OverlayEntry? _overlayEntry;
  AnimationController? _cardAnimationController;
  Animation<Offset>? _cardSlideAnimation;
  final GlobalKey _aiIconKey = GlobalKey();
  bool _isSpeechInitialized = false;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (!_stateNotifier.value.isCardVisible) {
      _stateNotifier.value = AIState();
    }
    _stateNotifier.addListener(_onStateChanged);
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _cardAnimationController!,
      curve: Curves.easeInOut,
    ));
    _cardAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {});
          _overlayEntry?.markNeedsBuild();
        }
      } else if (status == AnimationStatus.completed &&
          _stateNotifier.value.aiContent != null &&
          _stateNotifier.value.isFirstAppearance &&
          _settingsProvider.isAutoSpeakEnabled) {
        _ttsService.speak(_stateNotifier.value.aiContent!);
      }
    });
    _createOverlay();
    _initServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stateNotifier.value.isCardVisible && _settingsProvider.isAnimationEnabled) {
        _cardAnimationController!.forward();
      } else {
        _cardAnimationController!.value = 1.0;
      }
    });
    _settingsProvider.addListener(_onSettingsChanged);
  }

  void _initServices() async {
    await _ttsService.initialize();
    await _ttsService.setSpeed(_settingsProvider.ttsSpeed);
    _ttsService.setErrorHandler((msg) => _showErrorSnackBar('tts_error'));
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechService.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {});
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {});
            _showErrorSnackBar('speech_error');
          }
        },
      );
    }
  }

  void _onSettingsChanged() {
    if (!_settingsProvider.isAutoSpeakEnabled) {
      _ttsService.stop();
    }
    _ttsService.setSpeed(_settingsProvider.ttsSpeed);
    if (_stateNotifier.value.isCardVisible) {
      if (_settingsProvider.isAnimationEnabled) {
        if (_cardAnimationController!.status != AnimationStatus.completed &&
            _cardAnimationController!.status != AnimationStatus.forward) {
          _cardAnimationController!.forward();
        }
      } else {
        _cardAnimationController!.stop();
        _cardAnimationController!.value = 1.0;
      }
    } else {
      if (!_settingsProvider.isAnimationEnabled) {
        _cardAnimationController!.stop();
        _cardAnimationController!.value = 0.0;
      }
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
      _overlayEntry?.markNeedsBuild();
      if (_stateNotifier.value.isCardVisible) {
        if (_cardAnimationController!.status != AnimationStatus.completed &&
            _cardAnimationController!.status != AnimationStatus.forward &&
            _settingsProvider.isAnimationEnabled) {
          _cardAnimationController!.reset();
          _cardAnimationController!.forward();
        } else if (!_settingsProvider.isAnimationEnabled) {
          _cardAnimationController!.value = 1.0;
        }
      } else {
        if (_cardAnimationController!.status != AnimationStatus.dismissed &&
            _cardAnimationController!.status != AnimationStatus.reverse &&
            _settingsProvider.isAnimationEnabled) {
          _cardAnimationController!.reverse();
        } else if (!_settingsProvider.isAnimationEnabled) {
          _cardAnimationController!.value = 0.0;
        }
      }
    }
  }

  void _sendAIRequest(String input) async {
    try {
      final parsedContent = await _aiService.sendAIRequest(context, input);
      if (_stateNotifier.value.isCardVisible && _settingsProvider.isAnimationEnabled) {
        await _cardAnimationController!.reverse();
      }
      String? newAiContent;
      bool newIsCardVisible = false;
      if (parsedContent['content'] == 'null' || parsedContent['content'] == '') {
        newAiContent = parsedContent['content'] == 'null'
            ? 'Запрос не распознан. Попробуйте перефразировать.'
            : null;
        newIsCardVisible = parsedContent['content'] == 'null';
      } else {
        newAiContent = parsedContent['content'];
        newIsCardVisible = true;
      }
      _stateNotifier.value = AIState(
        aiContent: newAiContent,
        aiLink: parsedContent['link'] != 'null' ? parsedContent['link'] : null,
        navigation: parsedContent['navigation'] != 'null' ? parsedContent['navigation'] : null,
        isCardVisible: newIsCardVisible,
        isFirstAppearance: true,
      );
      if (_stateNotifier.value.isCardVisible) {
        if (_settingsProvider.isAnimationEnabled) {
          _cardAnimationController!.reset();
          _cardAnimationController!.forward();
        } else {
          _cardAnimationController!.value = 1.0;
        }
        _overlayEntry?.markNeedsBuild();
        _hideTimer?.cancel();
        if (_stateNotifier.value.isFirstAppearance) {
          _hideTimer = Timer(const Duration(seconds: 10), _hideCard);
        }
      }
      if (_stateNotifier.value.navigation != null) {
        final destination = AINavigation.getDestination(
          _stateNotifier.value.navigation,
          planets,
          widget.onThemeChanged,
          widget.isDarkTheme,
          widget.onFontSizeChanged,
          widget.fontSize,
        );
        if (destination != null) {
          AINavigation.navigate(context, destination).then((_) {
            if (mounted) {
              _createOverlay();
              _overlayEntry?.markNeedsBuild();
            }
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _navigateToSettings() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          onThemeChanged: widget.onThemeChanged,
          isDarkTheme: widget.isDarkTheme,
          onFontSizeChanged: widget.onFontSizeChanged,
          fontSize: widget.fontSize,
          onAnimationEnabledChanged: _settingsProvider.setAnimationEnabled,
          isAnimationEnabled: _settingsProvider.isAnimationEnabled,
          onAutoSpeakEnabledChanged: _settingsProvider.setAutoSpeakEnabled,
          isAutoSpeakEnabled: _settingsProvider.isAutoSpeakEnabled,
          onTtsSpeedChanged: _settingsProvider.setTtsSpeed,
          ttsSpeed: _settingsProvider.ttsSpeed,
          onAIModelChanged: _settingsProvider.setAIModel,
          aiModel: _settingsProvider.aiModel,
        ),
        settings: const RouteSettings(name: '/settings'),
      ),
    ).then((_) {
      if (mounted) {
        _createOverlay();
      }
    });
  }

  void _showErrorSnackBar(String errorCode) {
    ErrorSnackBar.show(context, errorCode, _aiIconKey);
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (mounted) {
        setState(() {});
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _hideCard() {
    _hideTimer?.cancel();
    _ttsService.stop();
    _stateNotifier.value = _stateNotifier.value.copyWith(
      isFirstAppearance: false,
      isCardVisible: false,
    );
    if (_settingsProvider.isAnimationEnabled) {
      _cardAnimationController!.reverse();
    } else {
      _cardAnimationController!.value = 0.0;
    }
  }

  void _restoreCard() {
    _hideTimer?.cancel();
    final bool canAnimate = TickerMode.of(context);
    if (canAnimate && _settingsProvider.isAnimationEnabled) {
      _cardAnimationController!.reverse().then((_) {
        _stateNotifier.value = _stateNotifier.value.copyWith(
          isCardVisible: false,
        );
        _overlayEntry?.markNeedsBuild();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _stateNotifier.value = _stateNotifier.value.copyWith(
              isCardVisible: true,
              isFirstAppearance: false,
            );
            _cardAnimationController!.reset();
            _cardAnimationController!.forward();
            _overlayEntry?.markNeedsBuild();
          }
        });
      });
    } else {
      _stateNotifier.value = _stateNotifier.value.copyWith(
        isCardVisible: true,
        isFirstAppearance: false,
      );
      _cardAnimationController!.value = 1.0;
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _createOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 32,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: AppTheme.getTextColor(context),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(6),
                  ),
                  onPressed: _navigateToSettings,
                ),
                const SizedBox(width: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: _aiIconKey,
                      icon: Icon(
                        Icons.assistant,
                        color: AppTheme.getTextColor(context),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(6),
                      ),
                      onPressed: () => AIFormDialog.show(
                        context: context,
                        speechService: _speechService,
                        onSubmit: _sendAIRequest,
                        ttsService: _ttsService,
                        vsync: this,
                        onSpeechError: _showErrorSnackBar,
                        onSpeechStatus: _handleSpeechStatus,
                        isDarkTheme: widget.isDarkTheme,
                        fontSize: widget.fontSize,
                      ),
                    ),
                    if (!_stateNotifier.value.isCardVisible && _stateNotifier.value.aiContent != null)
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: AppTheme.getTextColor(context),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        onPressed: _restoreCard,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_stateNotifier.value.isCardVisible && _stateNotifier.value.aiContent != null)
            ACard(
              state: _stateNotifier.value,
              animation: _cardSlideAnimation!,
              onHide: _hideCard,
              isDarkTheme: widget.isDarkTheme,
              fontSize: widget.fontSize,
            ),
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  @override
  void dispose() {
    _stateNotifier.removeListener(_onStateChanged);
    _settingsProvider.removeListener(_onSettingsChanged);
    _cardAnimationController?.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _speechService.stop();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}