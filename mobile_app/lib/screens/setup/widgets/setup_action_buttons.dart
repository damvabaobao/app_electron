import 'package:flutter/material.dart';

class SetupActionButtons extends StatelessWidget {
  final VoidCallback onCheckConnection;
  final VoidCallback onStartMeasurement;

  const SetupActionButtons({
    super.key,
    required this.onCheckConnection,
    required this.onStartMeasurement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCheckConnection,
            child: const Text('Kiểm tra kết nối'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: onStartMeasurement,
            child: const Text('Bắt đầu đo'),
          ),
        ),
      ],
    );
  }
}
