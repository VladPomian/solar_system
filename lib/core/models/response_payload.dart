class ResponsePayload {
  final String raw;
  final String time;
  final String dataBase64;
  final int size;
  final String status;
  final int? responseTime;

  ResponsePayload({
    required this.raw,
    required this.time,
    required this.dataBase64,
    required this.size,
    required this.status,
    this.responseTime,
  });
}