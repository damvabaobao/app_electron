import 'dart:async';
import 'dart:math';
import '../models/electrochemical_data.dart';
import '../models/measurement_config.dart';

class MeasurementService {
  final Random _random = Random();

  Timer? _timer;
  StreamController<ElectrochemicalData>? _controller;

  double _voltage = 0.0;
  int _currentCycle = 0;

  bool _isForward = true;
  bool _isMeasuring = false;

  // START MEASUREMENT
  Stream<ElectrochemicalData> startMeasurement(MeasurementConfig config) {
    // Nếu đang có phép đo cũ thì dừng trước.
    stopMeasurement();
    // Kiểm tra cấu hình.
    _validateConfig(config);
    _voltage = config.startVoltage;

    _currentCycle = 0;

    _isForward = true;

    _isMeasuring = true;

    _controller = StreamController<ElectrochemicalData>();

    // SAMPLE INTERVAL
    const sampleIntervalMs = 100;

    // SCAN RATE
    //
    // config.scanRate:
    // mV/s
    //
    // chuyển sang:
    // V/s
    final scanRateVPerSecond = config.scanRate / 1000.0;

    // Điện thế thay đổi trong một sample.
    final voltageStep = scanRateVPerSecond * (sampleIntervalMs / 1000.0);

    // TIMER
    _timer = Timer.periodic(const Duration(milliseconds: sampleIntervalMs), (
      timer,
    ) {
      if (!_isMeasuring) {
        return;
      }

      // CHECK CYCLE
      if (_currentCycle >= config.cycles) {
        _finishMeasurement();
        return;
      }

      // GENERATE CURRENT
      final current = _generateCurrent(
        voltage: _voltage,
        method: config.method,
      );

      // CREATE ELECTROCHEMICAL DATA
      final data = ElectrochemicalData(
        voltage: _voltage,
        current: current,
        timestamp: DateTime.now(),
      );

      // SEND DATA TO STREAM
      _controller?.add(data);

      // UPDATE VOLTAGE
      _updateVoltage(config: config, voltageStep: voltageStep);
    });

    return _controller!.stream;
  }

  // VALIDATE CONFIG

  void _validateConfig(MeasurementConfig config) {
    if (config.startVoltage == config.endVoltage) {
      throw ArgumentError('Start voltage and end voltage cannot be equal.');
    }
    if (config.scanRate <= 0) {
      throw ArgumentError('Scan rate must be greater than zero.');
    }
    if (config.cycles <= 0) {
      throw ArgumentError('Cycles must be greater than zero.');
    }
    const supportedMethods = ['CV', 'DPV', 'SWV'];
    if (!supportedMethods.contains(config.method)) {
      throw ArgumentError('Unsupported measurement method: ${config.method}');
    }
  }

  // UPDATE VOLTAGE
  void _updateVoltage({
    required MeasurementConfig config,
    required double voltageStep,
  }) {
    // FORWARD SCAN

    if (_isForward) {
      _voltage += voltageStep;

      final reachedEnd = voltageStep > 0
          ? _voltage >= config.endVoltage
          : _voltage <= config.endVoltage;

      if (reachedEnd) {
        _voltage = config.endVoltage;

        // CV:
        if (config.method == 'CV') {
          _isForward = false;
        } else {
          // DPV / SWV:
          // Một sweep hoàn thành.
          _currentCycle++;

          if (_currentCycle < config.cycles) {
            _voltage = config.startVoltage;
            _isForward = true;
          } else {
            _finishMeasurement();
          }
        }
      }

      return;
    }
    // REVERSE SCAN

    _voltage -= voltageStep;

    final reachedStart = voltageStep > 0
        ? _voltage <= config.startVoltage
        : _voltage >= config.startVoltage;

    if (reachedStart) {
      _voltage = config.startVoltage;

      _currentCycle++;

      if (_currentCycle < config.cycles) {
        _isForward = true;
      } else {
        _finishMeasurement();
      }
    }
  }

  // GENERATE CURRENT
  double _generateCurrent({required double voltage, required String method}) {
    switch (method) {
      case 'CV':
        return _generateCVCurrent(voltage);
      case 'DPV':
        return _generateDPVCurrent(voltage);
      case 'SWV':
        return _generateSWVCurrent(voltage);
      default:
        return 0.0;
    }
  }
  // CYCLIC VOLTAMMETRY

  double _generateCVCurrent(double voltage) {
    // Oxidation peak
    final oxidationPeak = exp(-pow(voltage - 0.20, 2) / 0.02);

    // Reduction peak
    final reductionPeak = exp(-pow(voltage + 0.35, 2) / 0.03);

    // Background current
    final background = 0.05 + 0.04 * voltage;

    // Combined electrochemical signal
    double current = background + oxidationPeak - 0.45 * reductionPeak;
    // Noise
    current += _generateNoise(amplitude: 0.03);
    return current;
  }

  // DIFFERENTIAL PULSE VOLTAMMETRY
  double _generateDPVCurrent(double voltage) {
    // DPV có peak hẹp hơn CV.

    final peak = exp(-pow(voltage - 0.20, 2) / 0.008);

    final secondPeak = exp(-pow(voltage - 0.55, 2) / 0.015);

    final background = 0.04 + 0.02 * voltage;

    double current = background + peak + 0.45 * secondPeak;

    current += _generateNoise(amplitude: 0.015);

    return current;
  }
  // SQUARE WAVE VOLTAMMETRY

  double _generateSWVCurrent(double voltage) {
    // SWV mô phỏng peak khá hẹp.

    final oxidationPeak = exp(-pow(voltage - 0.20, 2) / 0.012);

    final reductionPeak = exp(-pow(voltage + 0.25, 2) / 0.018);

    final background = 0.03 + 0.025 * voltage;

    double current = background + oxidationPeak - 0.35 * reductionPeak;

    current += _generateNoise(amplitude: 0.02);

    return current;
  }

  // NOISE
  double _generateNoise({required double amplitude}) {
    return (_random.nextDouble() - 0.5) * amplitude;
  }

  // FINISH MEASUREMENT
  void _finishMeasurement() {
    if (!_isMeasuring) {
      return;
    }

    _isMeasuring = false;

    _timer?.cancel();
    _timer = null;

    _controller?.close();
    _controller = null;
  }

  // STOP MEASUREMENT
  void stopMeasurement() {
    _isMeasuring = false;

    _timer?.cancel();
    _timer = null;

    _controller?.close();
    _controller = null;
  }

  // DISPOSE
  void dispose() {
    stopMeasurement();
  }
}
