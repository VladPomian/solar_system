class PredictionData {
  final List<MapEntry<DateTime, double>> cme;
  final List<MapEntry<DateTime, double>> flr;
  final List<MapEntry<DateTime, double>> gst;

  PredictionData({
    required this.cme,
    required this.flr,
    required this.gst,
  });

  Map<String, List<MapEntry<DateTime, double>>> toMap() {
    return {
      'CME': cme,
      'FLR': flr,
      'GST': gst,
    };
  }
}