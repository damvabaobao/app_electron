import 'dart:async';
import 'dart:math';
import '../models/electrochemical_data.dart';
import '../models/measurement_config.dart';

class MeasurementService {
  Timer? _timer;

  StreamController<ElectrochemicalData>? _controller;

  double _voltage = 0.0;

  int _cycle = 0;

  bool _reverse = false;

  Stream<ElectrochemicalData> startMeasurement(MeasurementConfig config) {
    stopMeasurement();

    _controller = StreamController<ElectrochemicalData>();

    _cycle = 1;
    _reverse = false;

    _voltage = config.startVoltage;

    const sampleIntervalMs = 50;

    final scanRateVPerSecond = config.scanRate / 1000.0;

    final voltageStep = scanRateVPerSecond * (sampleIntervalMs / 1000.0);

    _timer = Timer.periodic(const Duration(milliseconds: sampleIntervalMs), (
      timer,
    ) {
      if (_controller == null) {
        return;
      }

      _generateSample(config, voltageStep);
    });

    return _controller!.stream;
  }

  void _generateSample(MeasurementConfig config, double voltageStep) {
    final current = _generateCurrent(_voltage, config);

    _controller?.add(
      ElectrochemicalData(
        voltage: _voltage,
        current: current,
        timestamp: DateTime.now(),
      ),
    );

    _updateVoltage(config, voltageStep);
  }

  double _generateCurrent(double voltage, MeasurementConfig config) {
    if (config.method == 'CV') {
      return _generateCVCurrent(voltage);
    }

    if (config.method == 'DPV') {
      return _generateDPVCurrent(voltage);
    }

    return _generateCVCurrent(voltage);
  }

  double _generateCVCurrent(double voltage) {
    final peak = exp(-pow(voltage - 0.2, 2) / 0.02);

    final noise = (Random().nextDouble() - 0.5) * 0.02;

    return 0.1 + peak + noise;
  }

  double _generateDPVCurrent(double voltage) {
    final peak = exp(-pow(voltage - 0.2, 2) / 0.005);

    final noise = (Random().nextDouble() - 0.5) * 0.01;

    return 0.1 + peak + noise;
  }

  void _updateVoltage(MeasurementConfig config, double voltageStep) {
    if (config.method == 'CV') {
      if (!_reverse) {
        _voltage += voltageStep;

        if (_voltage >= config.endVoltage) {
          _voltage = config.endVoltage;

          _reverse = true;
        }
      } else {
        _voltage -= voltageStep;

        if (_voltage <= config.startVoltage) {
          if (_cycle >= config.cycles) {
            stopMeasurement();
            return;
          }

          _cycle++;

          _voltage = config.startVoltage;

          _reverse = false;
        }
      }
    } else {
      _voltage += voltageStep;

      if (_voltage >= config.endVoltage) {
        if (_cycle >= config.cycles) {
          stopMeasurement();
          return;
        }

        _cycle++;

        _voltage = config.startVoltage;
      }
    }
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
