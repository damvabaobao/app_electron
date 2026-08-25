import 'dart:async';
import 'dart:math';

import '../models/electrochemical_data.dart';
import '../models/measurement_config.dart';

class MeasurementService {
  final Random _random = Random();

  Timer? _timer;

  double _voltage = 0.0;

  StreamController<ElectrochemicalData>? _controller;

  Stream<ElectrochemicalData> startMeasurement(MeasurementConfig config) {
    // Nếu đang có phép đo cũ thì dừng trước
    stopMeasurement();

    _voltage = config.startVoltage;

    _controller = StreamController<ElectrochemicalData>();

    // Khoảng thời gian giữa hai mẫu
    const sampleIntervalMs = 100;

    /*
     * scanRate:
     * mV/s → V/s
     *
     * Ví dụ:
     * 100 mV/s = 0.1 V/s
     */
    final scanRateVPerSecond = config.scanRate / 1000.0;

    /*
     * Điện thế thay đổi bao nhiêu sau mỗi sample.
     *
     * Ví dụ:
     * 100 mV/s
     * với 100 ms/sample
     *
     * ΔV = 0.1 × 0.1 = 0.01 V
     */
    final voltageStep = scanRateVPerSecond * (sampleIntervalMs / 1000.0);

    _timer = Timer.periodic(const Duration(milliseconds: sampleIntervalMs), (
      timer,
    ) {
      // Đã vượt quá điện thế kết thúc
      if (_voltage > config.endVoltage) {
        stopMeasurement();
        return;
      }

      final current = _generateCurrent(_voltage, config.method);

      final data = ElectrochemicalData(
        voltage: _voltage,
        current: current,
        timestamp: DateTime.now(),
      );

      _controller?.add(data);

      _voltage += voltageStep;
    });

    return _controller!.stream;
  }

  double _generateCurrent(double voltage, String method) {
    /*
     * Peak chính.
     *
     * Đây chỉ là tín hiệu mô phỏng để kiểm tra
     * giao diện và pipeline.
     */
    final peak = exp(-pow(voltage - 0.2, 2) / 0.02);

    /*
     * CV và DPV hiện tại chỉ mô phỏng
     * hơi khác nhau để chúng ta kiểm tra UI.
     */
    double current;

    if (method == 'CV') {
      current = 0.1 + peak;
    } else {
      // DPV: peak hẹp hơn
      final dpvPeak = exp(-pow(voltage - 0.2, 2) / 0.008);

      current = 0.1 + dpvPeak;
    }

    // Noise mô phỏng
    final noise = (_random.nextDouble() - 0.5) * 0.05;

    return current + noise;
  }

  void stopMeasurement() {
    _timer?.cancel();
    _timer = null;

    _controller?.close();
    _controller = null;
  }

  void dispose() {
    stopMeasurement();
  }
}
