import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../measurement/widgets/voltammogram_chart.dart';

import '../../models/measurement_record.dart';
import '../../models/measuremen_session.dart';

class ResultScreen extends StatelessWidget {
  final MeasurementSession session;

  const ResultScreen({super.key, required this.session});

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (session.measurements.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Measurement Result'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Không có dữ liệu đo.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Result'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ====================================================
            // SESSION SUMMARY
            // ====================================================
            _buildSessionStatusCard(),

            const SizedBox(height: 20),

            _buildSessionInfo(),

            const SizedBox(height: 24),

            // ====================================================
            // EACH MEASUREMENT
            // ====================================================
            for (int i = 0; i < session.measurements.length; i++) ...[
              _buildMeasurementSection(session.measurements[i], i),

              const SizedBox(height: 24),
            ],

            // ====================================================
            // COMBINED VOLTAMMOGRAM
            // ====================================================
            _buildVoltammogram(),

            const SizedBox(height: 20),

            // ====================================================
            // COMPLETE
            // ====================================================
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(Icons.check),

                label: const Text(
                  'Hoàn tất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SESSION STATUS
  // ============================================================

  Widget _buildSessionStatusCard() {
    final totalSamples = session.measurements.fold<int>(
      0,
      (sum, measurement) => sum + measurement.data.length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 40, color: Colors.green),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Measurement Session Completed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${session.measurementCount} measurements • '
                    '$totalSamples samples',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SESSION INFORMATION
  // ============================================================

  Widget _buildSessionInfo() {
    final firstMeasurement = session.measurements.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Session Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Method', session.method),

            _infoRow('Measurements', session.measurementCount.toString()),

            _infoRow(
              'Start Voltage',
              '${firstMeasurement.startVoltage.toStringAsFixed(2)} V',
            ),

            _infoRow(
              'End Voltage',
              '${firstMeasurement.endVoltage.toStringAsFixed(2)} V',
            ),

            _infoRow('Scan Rate', '${firstMeasurement.scanRate} mV/s'),

            _infoRow('Cycles', firstMeasurement.cycles.toString()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ONE MEASUREMENT SECTION
  // ============================================================

  Widget _buildMeasurementSection(MeasurementRecord record, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Measurement ${index + 1}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        _buildMeasurementInfo(record),

        const SizedBox(height: 16),

        _buildPredictionCard(record),

        const SizedBox(height: 16),

        _buildPeakCard(record),

        const SizedBox(height: 16),

        _buildSignalFeaturesCard(record),

        const SizedBox(height: 16),

        _buildPhysicsFeaturesCard(record),
      ],
    );
  }

  // ============================================================
  // MEASUREMENT INFORMATION
  // ============================================================

  Widget _buildMeasurementInfo(MeasurementRecord record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Measurement Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Samples', record.data.length.toString()),

            if (record.data.isNotEmpty)
              _infoRow(
                'Potential Range',
                '${record.data.first.voltage.toStringAsFixed(2)} V'
                    ' → '
                    '${record.data.last.voltage.toStringAsFixed(2)} V',
              ),

            _infoRow('Scan Rate', '${record.scanRate} mV/s'),

            _infoRow('Cycles', record.cycles.toString()),

            _infoRow('Measurement ID', record.id),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI PREDICTION
  // ============================================================

  Widget _buildPredictionCard(MeasurementRecord record) {
    final confidence = record.confidence.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'AI Prediction',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              record.substance,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Confidence: '
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 16),

            Text(
              'Concentration: '
              '${record.concentration.toStringAsFixed(2)} µM',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PEAK INFORMATION
  // ============================================================

  Widget _buildPeakCard(MeasurementRecord record) {
    if (record.peak == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Text('Không phát hiện được peak.'),
        ),
      );
    }

    final peak = record.peak!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Peak Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow(
              'Peak Potential',
              '${peak.peakVoltage.toStringAsFixed(3)} V',
            ),

            _infoRow(
              'Peak Current',
              '${peak.peakCurrent.toStringAsFixed(4)} µA',
            ),

            _infoRow('Peak Width', '${peak.peakWidth.toStringAsFixed(3)} V'),

            _infoRow('Peak Area', peak.peakArea.toStringAsFixed(4)),

            _infoRow('Peak Prominence', peak.peakProminence.toStringAsFixed(4)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SIGNAL FEATURES
  // ============================================================

  Widget _buildSignalFeaturesCard(MeasurementRecord record) {
    if (record.signalFeatures == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Text('Chưa có signal features.'),
        ),
      );
    }

    final features = record.signalFeatures!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Signal Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Mean Current', features.meanCurrent.toStringAsFixed(4)),

            _infoRow('Current Std', features.stdCurrent.toStringAsFixed(4)),

            _infoRow('Max Current', features.maxCurrent.toStringAsFixed(4)),

            _infoRow('Min Current', features.minCurrent.toStringAsFixed(4)),

            _infoRow(
              'Mean Voltage',
              '${features.meanVoltage.toStringAsFixed(4)} V',
            ),

            _infoRow(
              'Voltage Range',
              '${features.voltageRange.toStringAsFixed(4)} V',
            ),

            _infoRow('Mean Gradient', features.meanGradient.toStringAsFixed(4)),

            _infoRow('Max Gradient', features.maxGradient.toStringAsFixed(4)),

            _infoRow('Min Gradient', features.minGradient.toStringAsFixed(4)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PHYSICS FEATURES
  // ============================================================

  Widget _buildPhysicsFeaturesCard(MeasurementRecord record) {
    if (record.physicsFeatures == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Text('Chưa có physics features.'),
        ),
      );
    }

    final features = record.physicsFeatures!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Physics Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Peak Current', features.peakCurrent.toStringAsFixed(4)),

            _infoRow(
              'Peak Potential',
              '${features.peakPotential.toStringAsFixed(4)} V',
            ),

            _infoRow(
              'Peak Width',
              '${features.peakWidth.toStringAsFixed(4)} V',
            ),

            _infoRow('Peak Area', features.peakArea.toStringAsFixed(4)),

            _infoRow(
              'Peak Prominence',
              features.peakProminence.toStringAsFixed(4),
            ),

            _infoRow('Peak Symmetry', features.peakSymmetry.toStringAsFixed(4)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMBINED VOLTAMMOGRAM
  // ============================================================

  Widget _buildVoltammogram() {
    if (session.measurements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Text('Không có dữ liệu voltammogram.'),
        ),
      );
    }

    final allSpots = <List<FlSpot>>[];

    for (final measurement in session.measurements) {
      final spots = measurement.data
          .map((point) => FlSpot(point.voltage, point.current))
          .toList();

      if (spots.isNotEmpty) {
        allSpots.add(spots);
      }
    }

    final firstMeasurement = session.measurements.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Combined Voltammogram',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        VoltammogramChart(
          allSpots: allSpots,
          currentSpots: const [],
          startVoltage: firstMeasurement.startVoltage,
          endVoltage: firstMeasurement.endVoltage,
          method: session.method,
        ),

        const SizedBox(height: 12),

        _buildMeasurementLegend(),
      ],
    );
  }

  // ============================================================
  // MEASUREMENT LEGEND
  // ============================================================

  Widget _buildMeasurementLegend() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,

      children: [
        for (int i = 0; i < session.measurements.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 14,
                height: 14,

                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Text('Measurement ${i + 1}'),
            ],
          ),
      ],
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
