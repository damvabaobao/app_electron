import 'measurement_record.dart';

class MeasurementSession {
  final String id;
  final DateTime timestamp;

  final String method;

  final List<MeasurementRecord> measurements;

  const MeasurementSession({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.measurements,
  });

  int get measurementCount => measurements.length;
}
