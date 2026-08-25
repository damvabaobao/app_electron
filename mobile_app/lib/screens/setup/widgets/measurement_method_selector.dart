import 'package:flutter/material.dart';

class MeasurementMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const MeasurementMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương pháp đo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'CV',
              label: Text('CV'),
              icon: Icon(Icons.show_chart),
            ),
            ButtonSegment<String>(
              value: 'DPV',
              label: Text('DPV'),
              icon: Icon(Icons.analytics),
            ),
          ],
          selected: {selectedMethod},
          onSelectionChanged: (Set<String> selection) {
            onChanged(selection.first);
          },
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.withValues(alpha: 0.08),
          ),
          child: Text(
            selectedMethod == 'CV'
                ? 'Cyclic Voltammetry'
                : 'Differential Pulse Voltammetry',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
