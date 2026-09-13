import 'package:flutter/material.dart';

import '../../models/measuremen_session.dart';
import '../../services/measurement_history_service.dart';
import '../result/result_screen.dart';
import '../../models/measurement_record.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyService = MeasurementHistoryService();

    final sessions = historyService.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement History'),
        centerTitle: true,
      ),

      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'Chưa có phép đo nào.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),

              itemBuilder: (context, index) {
                final session = sessions[index];

                return _buildHistoryCard(context, session);
              },
            ),
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _buildHistoryCard(BuildContext context, MeasurementSession session) {
    final firstMeasurement = session.measurements.isNotEmpty
        ? session.measurements.first
        : null;

    final totalSamples = session.measurements.fold<int>(0, (sum, measurement) {
      return sum + measurement.data.length;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ====================================================
            // HEADER
            // ====================================================
            Row(
              children: [
                const Icon(Icons.science, size: 30),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Measurement Session',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ====================================================
            // SESSION INFORMATION
            // ====================================================
            Text('Method: ${session.method}'),

            const SizedBox(height: 6),

            Text('Measurements: ${session.measurementCount}'),

            const SizedBox(height: 6),

            Text('Total samples: $totalSamples'),

            if (firstMeasurement != null) ...[
              const SizedBox(height: 6),

              Text('Scan Rate: ${firstMeasurement.scanRate} mV/s'),

              const SizedBox(height: 6),

              Text('Cycles: ${firstMeasurement.cycles}'),
            ],

            const SizedBox(height: 6),

            Text('Time: ${_formatDate(session.timestamp)}'),

            const SizedBox(height: 14),

            // ====================================================
            // MEASUREMENT SUMMARY
            // ====================================================
            _buildMeasurementSummary(session),

            const SizedBox(height: 16),

            // ====================================================
            // VIEW RESULT BUTTON
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(session: session),
                    ),
                  );
                },

                icon: const Icon(Icons.visibility),

                label: const Text('Xem kết quả'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEASUREMENT SUMMARY
  // ============================================================

  Widget _buildMeasurementSummary(MeasurementSession session) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Measurements in this session',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          for (int i = 0; i < session.measurements.length; i++)
            _buildMeasurementRow(session.measurements[i], i),
        ],
      ),
    );
  }

  // ============================================================
  // ONE MEASUREMENT ROW
  // ============================================================

  Widget _buildMeasurementRow(MeasurementRecord measurement, int index) {
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

    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,

            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 8),

          Expanded(child: Text('Measurement ${index + 1}')),

          Text('${measurement.data.length} samples'),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
