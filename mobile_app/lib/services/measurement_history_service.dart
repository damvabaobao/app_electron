import '../models/measuremen_session.dart';

class MeasurementHistoryService {
  static final MeasurementHistoryService _instance =
      MeasurementHistoryService._internal();

  factory MeasurementHistoryService() {
    return _instance;
  }

  MeasurementHistoryService._internal();

  final List<MeasurementSession> _sessions = [];

  List<MeasurementSession> get sessions {
    return List.unmodifiable(_sessions);
  }

  void addSession(MeasurementSession session) {
    _sessions.insert(0, session);
  }

  MeasurementSession? getSessionById(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteSession(String id) {
    _sessions.removeWhere((session) => session.id == id);
  }

  void clear() {
    _sessions.clear();
  }
}
