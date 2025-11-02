import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize({
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    return await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
        onStatus(status);
      },
      onError: (error) {
        _isListening = false;
        onError(error.toString());
      },
    );
  }

  Future<void> listen({
    required Function(String) onResult,
    required String localeId,
  }) async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    _isListening = true;
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  Future<void> stop() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
}