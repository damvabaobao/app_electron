import 'package:flutter/material.dart';

import '../../setup/setup_screen.dart';

class StartMeasurementButton extends StatelessWidget {
  const StartMeasurementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetupScreen()),
          );
        },
        icon: const Icon(Icons.play_arrow, size: 27),
        label: const Text(
          'Bắt đầu phép đo mới',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
