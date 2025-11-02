import 'dart:async';
import 'package:dart_amqp/dart_amqp.dart';
import '../models/response_payload.dart';

typedef OnResponseCallback = void Function(ResponsePayload payload);

class AmqpService {
  late String clientName;
  late String responseQueueName;
  String connectionStatus = "Готов к работе";

  Client? _amqpClient;
  Channel? _channel;
  Queue? _requestQueue;
  Queue? _responseQueue;
  Consumer? _consumer;

  OnResponseCallback? _onResponseCallback;
  bool _isConnected = false;
  Completer<void>? _responseCompleter;

  AmqpService() {
    clientName = "MobileClient_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    responseQueueName = "response_queue_$clientName";
  }

  void setOnResponseCallback(OnResponseCallback? cb) => _onResponseCallback = cb;

  Future<void> initialize({
    String host = "stend.declarant.info",
    int port = 5675,
    String username = "admin",
    String password = "newpassword",
  }) async {
    try {
      if (_isConnected && _amqpClient != null) {
        print("AMQP уже подключён");
        return;
      }

      print("Инициализация AMQP: host=$host, port=$port");
      final settings = ConnectionSettings(
        host: host,
        port: port,
        authProvider: PlainAuthenticator(username, password),
        connectTimeout: Duration(seconds: 5),
      );

      _amqpClient = Client(settings: settings);
      _channel = await _amqpClient!.channel();
      _requestQueue = await _channel!.queue("request_queue", durable: false);
      _responseQueue = await _channel!.queue(responseQueueName, durable: false, exclusive: true, autoDelete: true);
      _consumer = await _responseQueue!.consume(noAck: true);

      _consumer!.listen((AmqpMessage message) {
        final raw = message.payloadAsString;
        print("Получено сообщение: $raw");
        final parsed = _parseRawMessage(raw);
        if (_onResponseCallback != null) _onResponseCallback!(parsed);
        _responseCompleter?.complete();
        _responseCompleter = null;
      }, onError: (e) {
        _isConnected = false;
        connectionStatus = "Соединение потеряно: $e";
        print("Ошибка в потребителе: $e");
        _responseCompleter?.completeError(e);
        _responseCompleter = null;
      });

      _isConnected = true;
      connectionStatus = "Подключено к RabbitMQ через AMQP";
      print("AMQP успешно подключён");
    } catch (e) {
      _isConnected = false;
      connectionStatus = "Ошибка подключения: $e";
      print("Ошибка инициализации AMQP: $e");
    }
  }

  Future<bool> ensureConnected() async {
    if (!_isConnected || _channel == null || _requestQueue == null) {
      try {
        print("Попытка переподключения AMQP");
        if (_amqpClient != null) {
          await _amqpClient?.close();
          _channel = null;
          _requestQueue = null;
          _responseQueue = null;
          _consumer = null;
        }
        await initialize();
      } catch (e) {
        connectionStatus = "Не удалось переподключиться: $e (оффлайн-режим)";
        print("Ошибка переподключения: $e");
        return false;
      }
    }
    return _isConnected;
  }

  Future<void> sendRequest() async {
    if (!(await ensureConnected())) {
      throw Exception("Нет активного соединения с сервером или оффлайн-режим");
    }

    if (_requestQueue == null) {
      throw Exception("Очередь запросов не инициализирована");
    }

    _responseCompleter = Completer<void>();
    final msg = "Запрос от $clientName";
    final props = MessageProperties()..replyTo = responseQueueName;
    try {
      _requestQueue!.publish(msg, properties: props);
      print("Запрос отправлен: $msg");
      await _responseCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _responseCompleter?.completeError(TimeoutException('Сервер не ответил в течение 10 секунд'));
          _responseCompleter = null;
          throw TimeoutException('Сервер не ответил в течение 10 секунд');
        },
      );
    } catch (e) {
      _isConnected = false;
      connectionStatus = "Ошибка отправки: $e";
      print("Ошибка отправки запроса: $e");
      _responseCompleter = null;
      throw Exception("Ошибка отправки запроса: $e");
    }
  }

  ResponsePayload _parseRawMessage(String raw) {
    String timeToken = '';
    final timeMatch = RegExp(r'^\s*(\d{4}-\d{2}-\d{2}T[^\s]+)').firstMatch(raw);
    if (timeMatch != null) timeToken = timeMatch.group(1)!;

    final base64Matches = RegExp(r'[A-Za-z0-9+/=]{16,}').allMatches(raw).toList();
    String base64 = '';
    if (base64Matches.isNotEmpty) {
      base64Matches.sort((a, b) => b.group(0)!.length.compareTo(a.group(0)!.length));
      base64 = base64Matches.first.group(0)!;
    } else {
      final parts = raw.split(RegExp(r'\s+'));
      if (parts.length > 1) base64 = parts[1];
    }

    int size = 0;
    String status = '';
    int? responseTime;
    final tailParts = raw.split(RegExp(r'\s+')).reversed.toList();
    if (tailParts.isNotEmpty) {
      for (final t in tailParts) {
        final n = int.tryParse(t);
        if (n != null) {
          if (responseTime == null) {
            responseTime = n;
            continue;
          } else if (size == 0) {
            size = n;
            continue;
          }
        } else {
          if (status.isEmpty) status = t;
        }
      }
    }

    return ResponsePayload(
      raw: raw,
      time: timeToken,
      dataBase64: base64,
      size: size,
      status: status,
      responseTime: responseTime,
    );
  }

  Future<void> dispose() async {
    try {
      await _consumer?.cancel();
      await _channel?.close();
      await _amqpClient?.close();
      _isConnected = false;
      _consumer = null;
      _channel = null;
      _requestQueue = null;
      _responseQueue = null;
      _responseCompleter = null;
      print("AMQP ресурсы успешно закрыты");
    } catch (e) {
      print("Ошибка при закрытии AMQP ресурсов: $e");
    }
  }
}