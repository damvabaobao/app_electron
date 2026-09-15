import 'package:flutter/material.dart';

import '../../models/measuremen_session.dart';
import '../../services/measurement_history_service.dart';
import '../result/result_screen.dart';

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
                'Chưa có session đo nào.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final session = sessions[index];

                return _buildSessionCard(context, session);
              },
            ),
    );
  }

  Widget _buildSessionCard(BuildContext context, MeasurementSession session) {
    final measurements = session.measurements;

    final lastMeasurement = measurements.isNotEmpty ? measurements.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 32),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session ${session.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text('Method: ${session.method}'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _infoRow('Measurements', '${session.measurementCount} lần đo'),

            _infoRow('Time', _formatDate(session.timestamp)),

            if (lastMeasurement != null)
              _infoRow('Last prediction', lastMeasurement.substance),

            if (lastMeasurement != null)
              _infoRow(
                'Last confidence',
                '${(lastMeasurement.confidence * 100).toStringAsFixed(0)}%',
              ),

            const SizedBox(height: 14),

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
                label: const Text('Xem session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
