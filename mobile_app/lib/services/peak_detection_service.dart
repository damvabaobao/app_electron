import 'dart:math';

import '../models/electrochemical_data.dart';
import '../models/peak_result.dart';

class PeakDetectionService {
  PeakResult? detectPeak(List<ElectrochemicalData> data) {
    if (data.length < 3) {
      return null;
    }

    int peakIndex = 0;

    double maxCurrent = data.first.current;

    for (int i = 1; i < data.length; i++) {
      if (data[i].current > maxCurrent) {
        maxCurrent = data[i].current;
        peakIndex = i;
      }
    }

    final peak = data[peakIndex];

    // Tạm thời dùng khoảng 10% biên độ peak
    // để xác định vùng peak.
    final threshold = peak.current * 0.9;

    int left = peakIndex;
    int right = peakIndex;

    while (left > 0 && data[left].current >= threshold) {
      left--;
    }

    while (right < data.length - 1 && data[right].current >= threshold) {
      right++;
    }

    final peakWidth = data[right].voltage - data[left].voltage;

    double peakArea = 0;

    for (int i = left; i < right; i++) {
      final x1 = data[i].voltage;
      final x2 = data[i + 1].voltage;

      final y1 = data[i].current;
      final y2 = data[i + 1].current;

      peakArea += ((y1 + y2) / 2) * (x2 - x1);
    }

    final baseline = min(data[left].current, data[right].current);

    final prominence = peak.current - baseline;

    return PeakResult(
      peakVoltage: peak.voltage,
      peakCurrent: peak.current,
      peakWidth: peakWidth,
      peakArea: peakArea,
      peakProminence: prominence,
    );
  }
}
