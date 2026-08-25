import 'dart:math';

import '../models/electrochemical_data.dart';
import '../models/peak_result.dart';
import '../models/physics_features.dart';

class PhysicsFeatureService {
  PhysicsFeatures extract({
    required List<ElectrochemicalData> data,
    required PeakResult? peak,
  }) {
    if (data.isEmpty || peak == null) {
      return const PhysicsFeatures(
        peakCurrent: 0,
        peakPotential: 0,
        peakWidth: 0,
        peakArea: 0,
        peakProminence: 0,
        peakSymmetry: 0,
      );
    }

    final symmetry = _calculatePeakSymmetry(data, peak.peakVoltage);

    return PhysicsFeatures(
      peakCurrent: peak.peakCurrent,
      peakPotential: peak.peakVoltage,
      peakWidth: peak.peakWidth,
      peakArea: peak.peakArea,
      peakProminence: peak.peakProminence,
      peakSymmetry: symmetry,
    );
  }

  double _calculatePeakSymmetry(
    List<ElectrochemicalData> data,
    double peakVoltage,
  ) {
    if (data.length < 3) {
      return 0;
    }

    int peakIndex = 0;
    double smallestDifference = double.infinity;

    for (int i = 0; i < data.length; i++) {
      final difference = (data[i].voltage - peakVoltage).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        peakIndex = i;
      }
    }

    final peakCurrent = data[peakIndex].current;

    double leftVoltage = data.first.voltage;
    double rightVoltage = data.last.voltage;

    final halfHeight = peakCurrent / 2;

    for (int i = peakIndex; i > 0; i--) {
      if (data[i].current <= halfHeight) {
        leftVoltage = data[i].voltage;
        break;
      }
    }

    for (int i = peakIndex; i < data.length - 1; i++) {
      if (data[i].current <= halfHeight) {
        rightVoltage = data[i].voltage;
        break;
      }
    }

    final leftWidth = peakVoltage - leftVoltage;

    final rightWidth = rightVoltage - peakVoltage;

    if (rightWidth == 0) {
      return 0;
    }

    return leftWidth / rightWidth;
  }
}
