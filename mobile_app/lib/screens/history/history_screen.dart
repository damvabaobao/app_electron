import 'package:flutter/material.dart';

import '../../models/measurement_record.dart';
import '../../services/measurement_history_service.dart';
import '../result/result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyService = MeasurementHistoryService();

    final records = historyService.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement History'),
        centerTitle: true,
      ),

      body: records.isEmpty
          ? const Center(
              child: Text(
                'Chưa có phép đo nào.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = records[index];

                return _buildHistoryCard(context, record);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MeasurementRecord record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 30),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    record.substance,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  '${(record.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Concentration: '
              '${record.concentration.toStringAsFixed(2)} µM',
            ),

            const SizedBox(height: 6),

            Text('Method: ${record.method}'),

            const SizedBox(height: 6),

            Text('Samples: ${record.data.length}'),

            const SizedBox(height: 6),

            Text('Time: ${_formatDate(record.timestamp)}'),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(record: record),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
