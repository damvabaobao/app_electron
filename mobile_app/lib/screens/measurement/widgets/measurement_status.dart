import 'package:flutter/material.dart';

class MeasurementStatus extends StatelessWidget {
  const MeasurementStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, color: Colors.green, size: 12),

          SizedBox(width: 8),

          Text(
            'Raspberry Pi: Đang đo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
