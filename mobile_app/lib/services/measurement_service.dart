import 'dart:async';
import 'dart:math';

import '../models/electrochemical_data.dart';
import '../models/measurement_config.dart';

class MeasurementService {
  Timer? _timer;

  StreamController<ElectrochemicalData>? _controller;

  // ============================================================
  // MEASUREMENT STATE
  // ============================================================

  double _voltage = 0.0;

  int _cycle = 1;

  bool _reverse = false;

  int _sampleIndex = 0;

  // Dùng cho CA
  int _elapsedMilliseconds = 0;

  // Dùng cho ASV
  String _asvPhase = 'deposition';

  // Random generator
  final Random _random = Random();

  // ============================================================
  // START MEASUREMENT
  // ============================================================

  Stream<ElectrochemicalData> startMeasurement(MeasurementConfig config) {
    stopMeasurement();

    _controller = StreamController<ElectrochemicalData>();

    _cycle = 1;
    _reverse = false;
    _sampleIndex = 0;
    _elapsedMilliseconds = 0;
    _asvPhase = 'deposition';

    _voltage = config.startVoltage;

    const sampleIntervalMs = 50;

    _timer = Timer.periodic(const Duration(milliseconds: sampleIntervalMs), (
      timer,
    ) {
      if (_controller == null || _controller!.isClosed) {
        timer.cancel();
        return;
      }

      _generateSample(config, sampleIntervalMs);
    });

    return _controller!.stream;
  }

  // ============================================================
  // GENERATE SAMPLE
  // ============================================================

  void _generateSample(MeasurementConfig config, int sampleIntervalMs) {
    final current = _generateCurrent(config, sampleIntervalMs);

    _controller?.add(
      ElectrochemicalData(
        voltage: _voltage,
        current: current,
        timestamp: DateTime.now(),
      ),
    );

    _updateMeasurement(config, sampleIntervalMs);

    _sampleIndex++;
  }

  // ============================================================
  // CURRENT GENERATION
  // ============================================================

  double _generateCurrent(MeasurementConfig config, int sampleIntervalMs) {
    switch (config.method) {
      case 'CV':
        return _generateCVCurrent();

      case 'LSV':
        return _generateLSVCurrent();

      case 'SWV':
        return _generateSWVCurrent();

      case 'DPV':
        return _generateDPVCurrent();

      case 'ASV':
        return _generateASVCurrent(config);

      case 'CA':
        return _generateCACurrent(config, sampleIntervalMs);

      case 'EIS':
        return _generateEISCurrent(config);

      default:
        return _generateCVCurrent();
    }
  }

  // ============================================================
  // CV
  // ============================================================

  double _generateCVCurrent() {
    final voltageV = _voltage / 1000.0;

    // Oxidation peak
    final oxidationPeak = exp(-pow(voltageV - 0.20, 2) / 0.02);

    // Reduction peak
    final reductionPeak = exp(-pow(voltageV + 0.15, 2) / 0.03);

    final direction = _reverse ? -1.0 : 1.0;

    final faradaicCurrent =
        direction * oxidationPeak * 0.8 + direction * reductionPeak * 0.35;

    final capacitiveCurrent = 0.0005 * (_reverse ? -1 : 1);

    final noise = (_random.nextDouble() - 0.5) * 0.03;

    return faradaicCurrent + capacitiveCurrent + noise;
  }

  // ============================================================
  // LSV
  // ============================================================

  double _generateLSVCurrent() {
    final voltageV = _voltage / 1000.0;

    final oxidationPeak = exp(-pow(voltageV - 0.25, 2) / 0.018);

    final baseline = 0.002 * voltageV;

    final noise = (_random.nextDouble() - 0.5) * 0.025;

    return baseline + oxidationPeak + noise;
  }

  // ============================================================
  // SWV
  // ============================================================

  double _generateSWVCurrent() {
    final voltageV = _voltage / 1000.0;

    final peak = exp(-pow(voltageV - 0.20, 2) / 0.012);

    final pulseDirection = _sampleIndex.isEven ? 1.0 : -1.0;

    final noise = (_random.nextDouble() - 0.5) * 0.02;

    return pulseDirection * peak + noise;
  }

  // ============================================================
  // DPV
  // ============================================================

  double _generateDPVCurrent() {
    final voltageV = _voltage / 1000.0;

    final peak = exp(-pow(voltageV - 0.20, 2) / 0.008);

    final secondaryPeak = exp(-pow(voltageV + 0.10, 2) / 0.025);

    final noise = (_random.nextDouble() - 0.5) * 0.015;

    return 0.02 + peak * 0.9 + secondaryPeak * 0.2 + noise;
  }

  // ============================================================
  // ASV
  // ============================================================

  double _generateASVCurrent(MeasurementConfig config) {
    if (_asvPhase == 'deposition') {
      final noise = (_random.nextDouble() - 0.5) * 0.02;

      return -0.15 + noise;
    }

    if (_asvPhase == 'cleaning') {
      final noise = (_random.nextDouble() - 0.5) * 0.02;

      return 0.12 + noise;
    }

    if (_asvPhase == 'equilibrium') {
      final noise = (_random.nextDouble() - 0.5) * 0.01;

      return 0.01 + noise;
    }

    // Stripping / voltammetric scan
    final voltageV = _voltage / 1000.0;

    final strippingPeak = exp(-pow(voltageV - 0.35, 2) / 0.01);

    final noise = (_random.nextDouble() - 0.5) * 0.015;

    return strippingPeak + noise;
  }

  // ============================================================
  // CHRONOAMPEROMETRY
  // ============================================================

  double _generateCACurrent(MeasurementConfig config, int sampleIntervalMs) {
    final timeSeconds = _elapsedMilliseconds / 1000.0;

    // Cottrell-like decay
    final decay = 1.0 / sqrt(max(timeSeconds, 0.05));

    final baseCurrent = 0.8 * decay;

    final noise = (_random.nextDouble() - 0.5) * 0.015;

    return baseCurrent + noise;
  }

  // ============================================================
  // EIS
  // ============================================================

  double _generateEISCurrent(MeasurementConfig config) {
    /*
     * Lưu ý:
     *
     * ElectrochemicalData hiện tại chỉ có:
     *
     * voltage
     * current
     * timestamp
     *
     * nên chưa thể biểu diễn EIS đúng nghĩa
     * (frequency, impedance magnitude, phase).
     *
     * Ở bước này chỉ tạo tín hiệu mô phỏng
     * để kiểm tra luồng MeasurementService.
     */

    final progress = _sampleIndex / 100.0;

    final signal = 0.5 * exp(-progress * 0.03);

    final noise = (_random.nextDouble() - 0.5) * 0.02;

    return signal + noise;
  }

  // ============================================================
  // UPDATE MEASUREMENT
  // ============================================================

  void _updateMeasurement(MeasurementConfig config, int sampleIntervalMs) {
    switch (config.method) {
      case 'CV':
        _updateCV(config, sampleIntervalMs);
        break;

      case 'LSV':
      case 'SWV':
      case 'DPV':
        _updateLinearScan(config);
        break;

      case 'ASV':
        _updateASV(config, sampleIntervalMs);
        break;

      case 'CA':
        _updateCA(config, sampleIntervalMs);
        break;

      case 'EIS':
        _updateEIS(config);
        break;
    }
  }

  // ============================================================
  // CV UPDATE
  // ============================================================

  void _updateCV(MeasurementConfig config, int sampleIntervalMs) {
    final scanRate = config.scanRate; // mV/s

    final voltageStep = scanRate * (sampleIntervalMs / 1000.0);

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
  }

  // ============================================================
  // LSV / SWV / DPV UPDATE
  // ============================================================

  void _updateLinearScan(MeasurementConfig config) {
    final voltageStep = config.stepVoltage;

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

  // ============================================================
  // ASV UPDATE
  // ============================================================

  void _updateASV(MeasurementConfig config, int sampleIntervalMs) {
    if (config.useDeposition && _asvPhase == 'deposition') {
      _elapsedMilliseconds += sampleIntervalMs;

      if (_elapsedMilliseconds >= config.depositionTime) {
        _elapsedMilliseconds = 0;

        _asvPhase = 'cleaning';
      }

      return;
    }

    if (_asvPhase == 'cleaning') {
      _elapsedMilliseconds += sampleIntervalMs;

      if (_elapsedMilliseconds >= config.cleaningTime) {
        _elapsedMilliseconds = 0;

        _asvPhase = 'equilibrium';
      }

      return;
    }

    if (_asvPhase == 'equilibrium') {
      _elapsedMilliseconds += sampleIntervalMs;

      if (_elapsedMilliseconds >= config.equilibriumTime) {
        _elapsedMilliseconds = 0;

        _asvPhase = 'stripping';

        _voltage = config.startVoltage;
      }

      return;
    }

    // Stripping scan
    final voltageStep = config.scanRate * (sampleIntervalMs / 1000.0);

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

  // ============================================================
  // CA UPDATE
  // ============================================================

  void _updateCA(MeasurementConfig config, int sampleIntervalMs) {
    _elapsedMilliseconds += sampleIntervalMs;

    _voltage = config.appliedVoltage;

    final maxTime = config.timeRun * 1000;

    if (_elapsedMilliseconds >= maxTime) {
      stopMeasurement();
    }
  }

  // ============================================================
  // EIS UPDATE
  // ============================================================

  void _updateEIS(MeasurementConfig config) {
    _sampleIndex++;

    final totalPoints = config.sweepPoints * max(1, config.repeatTimes);

    if (_sampleIndex >= totalPoints) {
      stopMeasurement();
    }
  }

  // ============================================================
  // STOP
  // ============================================================

  void stopMeasurement() {
    _timer?.cancel();
    _timer = null;

    final controller = _controller;

    _controller = null;

    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    stopMeasurement();
  }
}
