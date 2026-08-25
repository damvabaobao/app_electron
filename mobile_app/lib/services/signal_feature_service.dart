import 'dart:math';

import '../models/electrochemical_data.dart';
import '../models/signal_features.dart';

class SignalFeatureService {
  SignalFeatures extract(List<ElectrochemicalData> data) {
    if (data.isEmpty) {
      return const SignalFeatures(
        meanCurrent: 0,
        stdCurrent: 0,
        maxCurrent: 0,
        minCurrent: 0,
        meanVoltage: 0,
        voltageRange: 0,
        meanGradient: 0,
        maxGradient: 0,
        minGradient: 0,
      );
    }

    final currents = data.map((e) => e.current).toList();
    final voltages = data.map((e) => e.voltage).toList();

    final meanCurrent = currents.reduce((a, b) => a + b) / currents.length;

    final meanVoltage = voltages.reduce((a, b) => a + b) / voltages.length;

    double variance = 0;

    for (final current in currents) {
      variance += pow(current - meanCurrent, 2).toDouble();
    }

    variance /= currents.length;

    final stdCurrent = sqrt(variance);

    final maxCurrent = currents.reduce(max);
    final minCurrent = currents.reduce(min);

    final voltageRange = voltages.reduce(max) - voltages.reduce(min);

    final gradients = <double>[];

    for (int i = 1; i < data.length; i++) {
      final deltaVoltage = data[i].voltage - data[i - 1].voltage;

      final deltaCurrent = data[i].current - data[i - 1].current;

      if (deltaVoltage != 0) {
        gradients.add(deltaCurrent / deltaVoltage);
      }
    }

    double meanGradient = 0;
    double maxGradient = 0;
    double minGradient = 0;

    if (gradients.isNotEmpty) {
      meanGradient = gradients.reduce((a, b) => a + b) / gradients.length;

      maxGradient = gradients.reduce(max);
      minGradient = gradients.reduce(min);
    }

    return SignalFeatures(
      meanCurrent: meanCurrent,
      stdCurrent: stdCurrent,
      maxCurrent: maxCurrent,
      minCurrent: minCurrent,
      meanVoltage: meanVoltage,
      voltageRange: voltageRange,
      meanGradient: meanGradient,
      maxGradient: maxGradient,
      minGradient: minGradient,
    );
  }
}
