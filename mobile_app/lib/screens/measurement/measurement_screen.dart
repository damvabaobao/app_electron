import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/electrochemical_data.dart';
import '../../models/measurement_config.dart';
import '../../services/measurement_service.dart';

import 'widgets/measurement_progress.dart';
import 'widgets/measurement_status.dart';
import 'widgets/voltammogram_chart.dart';
import 'widgets/measurement_controls.dart';

import '../result/result_screen.dart';
import '../../services/peak_detection_service.dart';
import '../../models/signal_features.dart';
import '../../services/signal_feature_service.dart';

import '../../models/physics_features.dart';
import '../../services/physics_feature_service.dart';
import '../../services/feature_vector_service.dart';
import '../../services/prediction_service.dart';
import '../../models/measurement_record.dart';

import '../../services/measurement_history_service.dart';

class MeasurementScreen extends StatefulWidget {
  final MeasurementConfig config;

  const MeasurementScreen({super.key, required this.config});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  final MeasurementService _measurementService = MeasurementService();
  final PeakDetectionService _peakDetectionService = PeakDetectionService();
  final SignalFeatureService _signalFeatureService = SignalFeatureService();

  //SignalFeatures? _signalFeatures;
  PredictionResult? _prediction;

  final PhysicsFeatureService _physicsFeatureService = PhysicsFeatureService();

  final FeatureVectorService _featureVectorService = FeatureVectorService();

  final PredictionService _predictionService = PredictionService();

  final MeasurementHistoryService _historyService = MeasurementHistoryService();

  final List<FlSpot> _spots = [];
  final List<ElectrochemicalData> _measurementData = [];

  StreamSubscription<ElectrochemicalData>? _subscription;

  double progress = 0.0;

  int sampleCount = 0;
  int totalSamples = 1;

  int _estimateTotalSamples() {
    final config = widget.config;

    switch (config.method) {
      case 'CA':
        if (config.timeInterval <= 0) {
          return 1;
        }

        return ((config.timeRun * 1000) / config.timeInterval).ceil();

      case 'EIS':
        return config.sweepPoints * config.repeatTimes;

      case 'CV':
        final voltageRange = (config.endVoltage - config.startVoltage).abs();

        if (config.scanRate <= 0) {
          return 1;
        }

        final timeSeconds = voltageRange / config.scanRate;

        final pointsPerSweep = (timeSeconds * 1000 / 50).ceil();

        return max(1, pointsPerSweep * 2 * config.cycles);

      case 'ASV':
        final depositionSamples = config.useDeposition
            ? (config.depositionTime / 50).ceil()
            : 0;

        final cleaningSamples = (config.cleaningTime / 50).ceil();

        final equilibriumSamples = (config.equilibriumTime / 50).ceil();

        final voltageRange = (config.endVoltage - config.startVoltage).abs();

        final scanTime = config.scanRate > 0
            ? voltageRange / config.scanRate
            : 0;

        final strippingSamples = (scanTime * 1000 / 50).ceil();

        return max(
          1,
          depositionSamples +
              cleaningSamples +
              equilibriumSamples +
              strippingSamples * config.cycles,
        );

      case 'LSV':
      case 'SWV':
      case 'DPV':
        final voltageRange = (config.endVoltage - config.startVoltage).abs();

        final step = config.stepVoltage.abs();

        if (step <= 0) {
          return 1;
        }

        final pointsPerSweep = (voltageRange / step).ceil() + 1;

        return max(1, pointsPerSweep * config.cycles);

      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();

    _startMeasurement();
  }

  void _startMeasurement() {
    _spots.clear();
    _measurementData.clear();

    sampleCount = 0;
    progress = 0.0;
    totalSamples = _estimateTotalSamples();

    _subscription = _measurementService.startMeasurement(widget.config).listen(
      (data) {
        setState(() {
          // Lưu dữ liệu gốc
          _measurementData.add(data);

          // Dữ liệu dùng để vẽ biểu đồ
          _spots.add(FlSpot(data.voltage, data.current));

          sampleCount++;

          progress = (sampleCount / totalSamples).clamp(0.0, 1.0);
        });
      },

      // Khi Stream kết thúc
      onDone: _measurementCompleted,
    );
  }

  void _measurementCompleted() {
    if (!mounted) return;

    // 1. Detect peak
    final peak = _peakDetectionService.detectPeak(_measurementData);

    // 2. Extract signal features
    final signalFeatures = _signalFeatureService.extract(_measurementData);

    // 3. Extract physics features
    final physicsFeatures = _physicsFeatureService.extract(
      data: _measurementData,
      peak: peak,
    );

    // 4. Build feature vector
    final featureVector = _featureVectorService.build(
      signal: signalFeatures,
      physics: physicsFeatures,
    );

    // 5. Prediction
    final prediction = _predictionService.predict(
      featureVector: featureVector.values,
      signalFeatures: signalFeatures,
      physicsFeatures: physicsFeatures,
    );

    setState(() {
      _prediction = prediction;
    });

    // 6. Create complete measurement record
    final record = MeasurementRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),

      method: widget.config.method,
      startVoltage: widget.config.startVoltage,
      endVoltage: widget.config.endVoltage,
      scanRate: widget.config.scanRate,
      cycles: widget.config.cycles,

      data: List.unmodifiable(_measurementData),

      peak: peak,
      signalFeatures: signalFeatures,
      physicsFeatures: physicsFeatures,

      featureVector: featureVector,

      substance: prediction.substance,
      confidence: prediction.confidence,
      concentration: prediction.concentration,
    );

    // Lưu phép đo vào history
    _historyService.addRecord(record);

    // Debug
    debugPrint('===== FEATURE VECTOR =====');
    debugPrint('Length: ${record.featureVector.length}');
    debugPrint(record.featureVector.values.toString());

    debugPrint('===== PREDICTION =====');
    debugPrint('Substance: ${record.substance}');
    debugPrint('Confidence: ${record.confidence}');
    debugPrint('Concentration: ${record.concentration}');

    // 7. Go to result screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(record: record)),
    );
  }

  void _stopMeasurement() {
    _subscription?.cancel();

    _measurementService.stopMeasurement();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã dừng phép đo')));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _measurementService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Measurement'), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const MeasurementStatus(),

              const SizedBox(height: 16),

              // Phương pháp đo
              Text(
                'Method: ${widget.config.method}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Khoảng điện thế
              Text(
                'Potential: '
                '${widget.config.startVoltage.toStringAsFixed(2)} mV'
                ' → '
                '${widget.config.endVoltage.toStringAsFixed(2)} mV',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 8),

              // Scan rate
              Text(
                'Scan Rate: '
                '${widget.config.scanRate} mV/s',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16),

              Text('Cycles: ${widget.config.cycles}'),
              const SizedBox(height: 16),

              MeasurementProgress(progress: progress, sampleCount: sampleCount),

              const SizedBox(height: 20),

              const Text(
                'Voltammogram',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              VoltammogramChart(
                spots: _spots,
                startVoltage: widget.config.startVoltage,
                endVoltage: widget.config.endVoltage,
                method: widget.config.method,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          children: [
                            const Text('Confidence'),

                            const SizedBox(height: 5),

                            Text(
                              _prediction == null
                                  ? '--'
                                  : '${(_prediction!.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          children: [
                            const Text('Concentration'),

                            const SizedBox(height: 5),

                            Text(
                              _prediction == null
                                  ? '--'
                                  : '${_prediction!.concentration.toStringAsFixed(2)} µM',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              MeasurementControls(onStop: _stopMeasurement),
            ],
          ),
        ),
      ),
    );
  }
}
