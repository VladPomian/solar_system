import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import '../models/prediction_data.dart';

class PredictionRepository {
  Future<PredictionData> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return PredictionData(
      cme: _parseCachedData(prefs.getString('cached_CME') ?? '[]'),
      flr: _parseCachedData(prefs.getString('cached_FLR') ?? '[]'),
      gst: _parseCachedData(prefs.getString('cached_GST') ?? '[]'),
    );
  }

  List<MapEntry<DateTime, double>> _parseCachedData(String jsonString) {
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => MapEntry(
          DateTime.parse(e['date']),
          e['value'] as double,
        )).toList();
  }

  Future<void> cacheData(String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      final decoded = utf8.decode(bytes);
      final xmlDoc = XmlDocument.parse(decoded);
      final prefs = await SharedPreferences.getInstance();

      for (final cat in ['CME', 'FLR', 'GST']) {
        final nodes = xmlDoc.findAllElements(cat);
        if (nodes.isNotEmpty) {
          final data = nodes.expand((n) => n.findElements('record')).map((rec) {
            final date = DateTime.parse(rec.findElements('date').first.innerText);
            final value = double.parse(rec.findElements('value').first.innerText);
            return MapEntry(date, value);
          }).toList();
          await prefs.setString('cached_$cat', jsonEncode(data.map((e) => {'date': e.key.toIso8601String(), 'value': e.value}).toList()));
        }
      }
    } catch (e) {
      print('Ошибка кеширования: $e');
    }
  }
}