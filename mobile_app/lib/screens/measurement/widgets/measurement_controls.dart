import 'package:flutter/material.dart';

class MeasurementControls extends StatelessWidget {
  final VoidCallback onStop;

  const MeasurementControls({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('Lưu cấu hình'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: onStop,
            child: const Text('Dừng đo'),
          ),
        ),
      ],
    );
  }
}
