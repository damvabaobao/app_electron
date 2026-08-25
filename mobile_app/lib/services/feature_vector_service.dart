import '../models/feature_vector.dart';
import '../models/signal_features.dart';
import '../models/physics_features.dart';

class FeatureVectorService {
  FeatureVector build({
    required SignalFeatures signal,
    required PhysicsFeatures physics,
  }) {
    return FeatureVector(
      values: [
        // Signal features
        signal.meanCurrent,
        signal.stdCurrent,
        signal.maxCurrent,
        signal.minCurrent,
        signal.meanVoltage,
        signal.voltageRange,
        signal.meanGradient,
        signal.maxGradient,
        signal.minGradient,

        // Physics features
        physics.peakCurrent,
        physics.peakPotential,
        physics.peakWidth,
        physics.peakArea,
        physics.peakProminence,
        physics.peakSymmetry,
      ],
    );
  }
}
