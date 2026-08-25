import 'electrochemical_data.dart';
import 'peak_result.dart';
import 'signal_features.dart';
import 'physics_features.dart';
import 'feature_vector.dart';

class MeasurementRecord {
  final String id;
  final DateTime timestamp;

  final String method;

  final double startVoltage;
  final double endVoltage;
  final double scanRate;
  final int cycles;

  final List<ElectrochemicalData> data;

  final PeakResult? peak;
  final SignalFeatures? signalFeatures;
  final PhysicsFeatures? physicsFeatures;

  final FeatureVector featureVector;

  final String substance;
  final double confidence;
  final double concentration;

  const MeasurementRecord({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.startVoltage,
    required this.endVoltage,
    required this.scanRate,
    required this.cycles,
    required this.data,
    required this.peak,
    required this.signalFeatures,
    required this.physicsFeatures,
    required this.featureVector,
    required this.substance,
    required this.confidence,
    required this.concentration,
  });
}
