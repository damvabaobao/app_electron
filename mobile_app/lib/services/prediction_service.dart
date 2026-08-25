import '../models/signal_features.dart';
import '../models/physics_features.dart';
import '../models/feature_definition.dart';

class PredictionResult {
  final String substance;
  final double confidence;
  final double concentration;

  const PredictionResult({
    required this.substance,
    required this.confidence,
    required this.concentration,
  });
}

class PredictionService {
  PredictionResult predict({
    required List<double> featureVector,
    required SignalFeatures signalFeatures,
    required PhysicsFeatures physicsFeatures,
  }) {
    // Kiểm tra feature vector
    if (featureVector.length != FeatureDefinition.length) {
      return const PredictionResult(
        substance: 'Unknown',
        confidence: 0.0,
        concentration: 0.0,
      );
    }

    // TODO:
    // Sau này thay phần này bằng XGBoost model.

    if (physicsFeatures.peakCurrent > 0.8) {
      return const PredictionResult(
        substance: 'Dopamine',
        confidence: 0.80,
        concentration: 25.0,
      );
    }

    return const PredictionResult(
      substance: 'Unknown',
      confidence: 0.45,
      concentration: 0.0,
    );
  }
}
