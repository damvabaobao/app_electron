import '../models/measurement_record.dart';

class MeasurementHistoryService {
  static final MeasurementHistoryService _instance =
      MeasurementHistoryService._internal();

  factory MeasurementHistoryService() {
    return _instance;
  }

  MeasurementHistoryService._internal();

  final List<MeasurementRecord> _records = [];

  List<MeasurementRecord> get records {
    return List.unmodifiable(_records);
  }

  void addRecord(MeasurementRecord record) {
    _records.insert(0, record);
  }

  MeasurementRecord? getRecordById(String id) {
    try {
      return _records.firstWhere((record) => record.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteRecord(String id) {
    _records.removeWhere((record) => record.id == id);
  }

  void clear() {
    _records.clear();
  }
}
