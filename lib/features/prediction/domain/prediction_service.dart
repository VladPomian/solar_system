import 'package:flutter/material.dart';
import '../../../core/services/amqp_service.dart';
import '../../../core/utils/decoder.dart';
import '../data/repositories/prediction_repository.dart';
import '../data/models/prediction_data.dart';

class PredictionService {
  final AmqpService amqpService;
  final PredictionRepository repository;

  PredictionService({required this.amqpService, required this.repository});

  void clearOnResponseCallback() {
    amqpService.setOnResponseCallback(null);
  }

  Future<PredictionData> initialize(
      BuildContext context,
      Function(String) onStatusUpdate,
      Function(DateTime?) onDateUpdate) async {
    try {
      await amqpService.initialize();
      onStatusUpdate(amqpService.connectionStatus);

      amqpService.setOnResponseCallback((payload) {
        final serverDate = _parseDateTimeFromRaw(payload.raw);
        onDateUpdate(serverDate ?? DateTime.now());

        if (payload.raw.contains('Success')) {
          onStatusUpdate('Запрос успешен');
        } else {
          onStatusUpdate('Ошибка в ответе сервера');
        }

        if (!payload.raw.contains('Success') && payload.dataBase64.trim().isNotEmpty) {
          try {
            Decoder.decodeErrorDataAndShowMessage(context, payload.dataBase64);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка декодирования: $e')),
              );
            }
          }
        }

        if (!payload.raw.contains('Success')) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Получен ответ с ошибкой: ${payload.raw}')),
            );
          }
        }

        if (payload.raw.contains('Success') && payload.dataBase64.isNotEmpty) {
          repository.cacheData(payload.dataBase64);
        }
      });

      await sendRequest();
      return repository.loadCachedData();
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Ошибка инициализации AMQP: $e');
      }
      onStatusUpdate('Оффлайн-режим: использование кеша');
      return repository.loadCachedData();
    }
  }

  Future<void> sendRequest() async {
    try {
      await amqpService.sendRequest();
    } catch (e) {
      throw Exception('Нет соединения: $e');
    }
  }

  DateTime? _parseDateTimeFromRaw(String raw) {
    try {
      final regExp = RegExp(r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
      final match = regExp.firstMatch(raw);
      if (match != null) {
        return DateTime.parse(match.group(1)!.replaceFirst(' ', 'T'));
      }
    } catch (_) {}
    return null;
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }
}