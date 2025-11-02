class AppConstants {
  static const Map<String, double> thresholds = {
    'CME': 730.0,
    'FLR': 5.3,
    'GST': 7.2,
  };

  static const Map<String, double> baseValues = {
    'CME': 500.0,
    'FLR': 3.0,
    'GST': 4.0,
  };

  static const Map<String, String> categoryFullNames = {
    'CME': 'Выбросы корональной массы (CME)',
    'FLR': 'Солнечные вспышки (FLR)',
    'GST': 'Геомагнитная возмущённость (GST)',
  };

  static const Map<String, String> categoryExplanations = {
    'CME': 'Значения выше порога могут указывать на крупные события, влияющие на космическую погоду.',
    'FLR': 'Значения выше порога считаются сильными вспышками, потенциально вызывающими радиопомехи.',
    'GST': 'Значения выше порога — существенные нарушения, которые могут повлиять на энергосистемы и спутники.',
  };
}