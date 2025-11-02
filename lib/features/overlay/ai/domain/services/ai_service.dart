import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AIService {
  static const String _apiKey = 'csk-399weyxptw6wd3mwk98645jymp8xwkfv8pv6k6jnch4mw9tv';
  static const String _apiUrl = 'https://api.cerebras.ai/v1/chat/completions';

  Future<Map<String, dynamic>> sendAIRequest(BuildContext context, String input) async { 
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': settingsProvider.aiModel.modelId,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Ответь в формате JSON: {"navigation": "Mercury|Venus|Earth|Mars|Jupiter|Saturn|Uranus|Neptune|Pluto|Simulation|Prediction|null", "link": "URL или null", "content": "Краткий текст до 20 символов"}. Для запросов о Меркурии верни "navigation": "Mercury", о Венере — "Venus", о Земле — "Earth", о Марсе — "Mars", о Юпитере — "Jupiter", о Сатурне — "Saturn", об Уране — "Uranus", о Нептуне — "Neptune", о Плутоне — "Pluto", о симуляции Солнечной системы — "Simulation", о солнечных явлениях, влиянии Солнца или их предсказании — "Prediction", для других тем — "link" с URL на русский ресурс. Убедись, что JSON валидный.'
                },
                {'role': 'user', 'content': input},
              ],
              'max_tokens': 100,
              'temperature': 0.7,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        final parsedContent = jsonDecode(data['choices'][0]['message']['content']);
        parsedContent['link'] = parsedContent['link'] == 'null' || parsedContent['link'] == null ? null : parsedContent['link'];
        parsedContent['navigation'] = parsedContent['navigation'] == 'null' ? null : parsedContent['navigation'];
        return parsedContent;
      } else {
        throw Exception('HTTP ошибка: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException || e is TimeoutException) {
        throw Exception('503');
      } else {
        throw Exception('unknown');
      }
    } finally {
      client.close();
    }
  }
}