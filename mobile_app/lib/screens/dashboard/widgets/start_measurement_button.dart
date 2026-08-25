import 'package:flutter/material.dart';
import '../../setup/setup_screen.dart';

class StartMeasurementButton extends StatelessWidget {
  const StartMeasurementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: chuyển sang màn hình Setup
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetupScreen()),
          );
        },
        icon: const Icon(Icons.science),
        label: const Text(
          'Bắt đầu phép đo mới',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
