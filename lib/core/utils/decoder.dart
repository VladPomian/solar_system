import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

enum MessageBoxIcon { Information, Warning, Error }

class Decoder {
  static void decodeErrorDataAndShowMessage(BuildContext context, String encodedBase64) {
    if (encodedBase64.trim().isEmpty) return;

    String cleaned = _cleanBase64String(encodedBase64);

    try {
      final bytes = base64Decode(cleaned);
      final decoded = utf8.decode(bytes);

      try {
        final xmlDoc = XmlDocument.parse(decoded);
        final msg = _extractMessageFromXml(xmlDoc);
        _showMessageDialog(context, msg, MessageBoxIcon.Information);
      } catch (e) {
        _showMessageDialog(context, 'Декодированное сообщение:\n\n$decoded', MessageBoxIcon.Warning);
      }
    } catch (e) {
      _showMessageDialog(context, 'Неверные данные Base64: $e\n\nИсходное: $encodedBase64', MessageBoxIcon.Error);
    }
  }

  static String _cleanBase64String(String s) {
    final only = RegExp(r'[A-Za-z0-9+/=]+').allMatches(s).map((m) => m.group(0)).join('');
    return only.isEmpty ? s : only;
  }

  static String _extractMessageFromXml(XmlDocument xmlDoc) {
    final sb = StringBuffer();
    final categories = ['CME', 'FLR', 'GST'];
    bool found = false;
    for (final cat in categories) {
      final nodes = xmlDoc.findAllElements(cat);
      if (nodes.isEmpty) continue;
      found = true;
      for (final n in nodes) {
        sb.writeln('Категория: $cat');
        for (final rec in n.findElements('record')) {
          final date = rec.findElements('date').isNotEmpty ? rec.findElements('date').first.innerText : '—';
          final value = rec.findElements('value').isNotEmpty ? rec.findElements('value').first.innerText : '—';
          sb.writeln('  Дата: $date  Значение: $value');
        }
      }
    }

    if (!found) {
      return 'XML успешно декодирован, но знакомые категории не найдены.\n\n${xmlDoc.toXmlString(pretty: true)}';
    }
    return sb.toString();
  }

  static void _showMessageDialog(BuildContext context, String message, MessageBoxIcon icon) {
    IconData iconData;
    String title;
    switch (icon) {
      case MessageBoxIcon.Error:
        iconData = Icons.error;
        title = 'Ошибка';
        break;
      case MessageBoxIcon.Warning:
        iconData = Icons.warning;
        title = 'Предупреждение';
        break;
      default:
        iconData = Icons.info;
        title = 'Информация';
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(children: [Icon(iconData), const SizedBox(width: 8), Text(title)]),
        content: SingleChildScrollView(child: SelectableText(message)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
        ],
      ),
    );
  }
}