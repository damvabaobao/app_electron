import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../measurement/widgets/voltammogram_chart.dart';

import '../../models/electrochemical_data.dart';
import '../../models/peak_result.dart';

import '../../models/signal_features.dart';

import '../../models/physics_features.dart';
import '../../services/prediction_service.dart';

import '../../models/measurement_record.dart';

class ResultScreen extends StatelessWidget {
  final MeasurementRecord record;

  const ResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
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
            _buildStatusCard(),

            const SizedBox(height: 20),

            _buildMeasurementInfo(),

            const SizedBox(height: 20),

            _buildPredictionCard(),

            const SizedBox(height: 20),

            _buildPeakCard(),

            const SizedBox(height: 20),

            _buildSignalFeaturesCard(),

            const SizedBox(height: 20),

            _buildVoltammogram(),

            const SizedBox(height: 20),

            _buildPhysicsFeaturesCard(),

            const SizedBox(height: 20),

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

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 40, color: Colors.green),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Measurement Completed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text('${record.data.length} samples collected'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInfo() {
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

            _infoRow('Method', record.method),

            _infoRow('Samples', record.data.length.toString()),

            if (record.data.isNotEmpty)
              _infoRow(
                'Potential Range',
                '${record.data.first.voltage.toStringAsFixed(2)} V → '
                    '${record.data.last.voltage.toStringAsFixed(2)} V',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    final confidence = record.confidence.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'AI Prediction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              record.substance,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
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

  Widget _buildPeakCard() {
    if (record.peak == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Không phát hiện được peak.'),
        ),
      );
    }

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
              '${record.peak!.peakVoltage.toStringAsFixed(3)} V',
            ),

            _infoRow(
              'Peak Current',
              '${record.peak!.peakCurrent.toStringAsFixed(4)} µA',
            ),

            _infoRow(
              'Peak Width',
              '${record.peak!.peakWidth.toStringAsFixed(3)} V',
            ),

            _infoRow('Peak Area', record.peak!.peakArea.toStringAsFixed(4)),

            _infoRow(
              'Peak Prominence',
              record.peak!.peakProminence.toStringAsFixed(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalFeaturesCard() {
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

  Widget _buildPhysicsFeaturesCard() {
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

  Widget _buildVoltammogram() {
    if (record.data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Không có dữ liệu voltammogram.'),
        ),
      );
    }

    final spots = record.data
        .map((point) => FlSpot(point.voltage, point.current))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voltammogram',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        VoltammogramChart(
          spots: spots,
          startVoltage: record.startVoltage,
          endVoltage: record.endVoltage,
          method: record.method,
        ),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
