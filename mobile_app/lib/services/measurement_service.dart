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

  double _elapsedSeconds = 0.0;

  // ASV phase
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
    _elapsedSeconds = 0.0;

    _asvPhase = config.useDeposition ? 'deposition' : 'equilibrium';

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

    final data = _createData(config, current);

    _controller?.add(data);

    _updateMeasurement(config, sampleIntervalMs);

    if (config.method != 'EIS') {
      _sampleIndex++;
    }
  }

  // ============================================================
  // CREATE ELECTROCHEMICAL DATA
  // ============================================================

  ElectrochemicalData _createData(MeasurementConfig config, double current) {
    if (config.method == 'CA') {
      return ElectrochemicalData(
        voltage: config.appliedVoltage,
        current: current,
        timestamp: DateTime.now(),
        time: _elapsedSeconds,
      );
    }

    if (config.method == 'EIS') {
      final frequency = _calculateEISFrequency(config);

      final impedance = _calculateEISImpedance(frequency);

      final phase = _calculateEISPhase(frequency);

      return ElectrochemicalData(
        voltage: _voltage,
        current: current,
        timestamp: DateTime.now(),
        frequency: frequency,
        impedanceMagnitude: impedance,
        phase: phase,
      );
    }

    return ElectrochemicalData(
      voltage: _voltage,
      current: current,
      timestamp: DateTime.now(),
    );
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
        return _generateCACurrent();

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

    final oxidationPeak = exp(-pow(voltageV - 0.20, 2) / 0.02);

    final reductionPeak = exp(-pow(voltageV + 0.15, 2) / 0.03);

    final direction = _reverse ? -1.0 : 1.0;

    final faradaicCurrent =
        direction * oxidationPeak * 0.8 + direction * reductionPeak * 0.35;

    final capacitiveCurrent = 0.0005 * (_reverse ? -1.0 : 1.0);

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
    switch (_asvPhase) {
      case 'deposition':
        return -0.15 + (_random.nextDouble() - 0.5) * 0.02;

      case 'cleaning':
        return 0.12 + (_random.nextDouble() - 0.5) * 0.02;

      case 'equilibrium':
        return 0.01 + (_random.nextDouble() - 0.5) * 0.01;

      case 'stripping':
        final voltageV = _voltage / 1000.0;

        final strippingPeak = exp(-pow(voltageV - 0.35, 2) / 0.01);

        final noise = (_random.nextDouble() - 0.5) * 0.015;

        return strippingPeak + noise;

      default:
        return 0.0;
    }
  }

  // ============================================================
  // CHRONOAMPEROMETRY
  // ============================================================

  double _generateCACurrent() {
    final time = max(_elapsedSeconds, 0.05);

    final decay = 1.0 / sqrt(time);

    final baseCurrent = 0.8 * decay;

    final noise = (_random.nextDouble() - 0.5) * 0.015;

    return baseCurrent + noise;
  }

  // ============================================================
  // EIS
  // ============================================================

  double _generateEISCurrent(MeasurementConfig config) {
    final frequency = _calculateEISFrequency(config);

    final impedance = _calculateEISImpedance(frequency);

    final voltageAmplitude = config.amplitude / 1000.0;

    final currentAmplitude = voltageAmplitude / max(impedance, 0.001);

    final noise = (_random.nextDouble() - 0.5) * currentAmplitude * 0.05;

    return currentAmplitude + noise;
  }

  // ============================================================
  // EIS FREQUENCY
  // ============================================================

  double _calculateEISFrequency(MeasurementConfig config) {
    if (config.sweepPoints <= 1) {
      return config.startFrequency;
    }

    final start = max(config.startFrequency, 0.001);

    final stop = max(config.stopFrequency, start);

    final progress = _sampleIndex / (config.sweepPoints - 1);

    final clampedProgress = progress.clamp(0.0, 1.0);

    final logStart = log(start);
    final logStop = log(stop);

    return exp(logStart + (logStop - logStart) * clampedProgress);
  }

  // ============================================================
  // EIS IMPEDANCE
  // ============================================================

  double _calculateEISImpedance(double frequency) {
    const resistance = 100.0;

    const capacitance = 0.000001;

    final omega = 2 * pi * frequency;

    final capacitiveReactance = 1.0 / max(omega * capacitance, 0.000001);

    return sqrt(pow(resistance, 2) + pow(capacitiveReactance, 2));
  }

  // ============================================================
  // EIS PHASE
  // ============================================================

  double _calculateEISPhase(double frequency) {
    const resistance = 100.0;

    const capacitance = 0.000001;

    final omega = 2 * pi * frequency;

    final reactance = 1.0 / max(omega * capacitance, 0.000001);

    return -atan(reactance / resistance) * 180 / pi;
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
    final voltageStep = config.scanRate * (sampleIntervalMs / 1000.0);

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
      _voltage = config.endVoltage;

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
    // ----------------------------------------------------------
    // DEPOSITION
    // ----------------------------------------------------------

    if (config.useDeposition && _asvPhase == 'deposition') {
      _elapsedSeconds += sampleIntervalMs / 1000.0;

      _voltage = config.depositionVoltage;

      if (_elapsedSeconds >= config.depositionTime / 1000.0) {
        _elapsedSeconds = 0.0;

        _asvPhase = 'cleaning';
      }

      return;
    }

    // ----------------------------------------------------------
    // CLEANING
    // ----------------------------------------------------------

    if (_asvPhase == 'cleaning') {
      _elapsedSeconds += sampleIntervalMs / 1000.0;

      _voltage = config.cleaningVoltage;

      if (_elapsedSeconds >= config.cleaningTime / 1000.0) {
        _elapsedSeconds = 0.0;

        _asvPhase = 'equilibrium';
      }

      return;
    }

    // ----------------------------------------------------------
    // EQUILIBRIUM
    // ----------------------------------------------------------

    if (_asvPhase == 'equilibrium') {
      _elapsedSeconds += sampleIntervalMs / 1000.0;

      _voltage = config.equilibriumVoltage;

      if (_elapsedSeconds >= config.equilibriumTime / 1000.0) {
        _elapsedSeconds = 0.0;

        _asvPhase = 'stripping';

        _voltage = config.startVoltage;
      }

      return;
    }

    // ----------------------------------------------------------
    // STRIPPING
    // ----------------------------------------------------------

    final voltageStep = config.scanRate * (sampleIntervalMs / 1000.0);

    _voltage += voltageStep;

    if (_voltage >= config.endVoltage) {
      _voltage = config.endVoltage;

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
    _elapsedSeconds += sampleIntervalMs / 1000.0;

    _voltage = config.appliedVoltage;

    final maxTime = config.timeRun.toDouble();

    if (_elapsedSeconds >= maxTime) {
      stopMeasurement();
    }
  }

  // ============================================================
  // EIS UPDATE
  // ============================================================

  void _updateEIS(MeasurementConfig config) {
    final pointsPerSweep = max(config.sweepPoints, 1);

    final totalPoints = pointsPerSweep * max(config.repeatTimes, 1);

    _sampleIndex++;

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
