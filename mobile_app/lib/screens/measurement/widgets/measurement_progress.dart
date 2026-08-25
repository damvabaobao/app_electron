import 'package:flutter/material.dart';

class MeasurementProgress extends StatelessWidget {
  final double progress;
  final int sampleCount;

  const MeasurementProgress({
    super.key,
    required this.progress,
    required this.sampleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 8),

        Text('Sampling: $sampleCount points'),
      ],
    );
  }
}
