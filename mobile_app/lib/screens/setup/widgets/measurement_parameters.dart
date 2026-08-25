import 'package:flutter/material.dart';

class MeasurementParameters extends StatelessWidget {
  final TextEditingController scanRateController;
  final TextEditingController cyclesController;

  const MeasurementParameters({
    super.key,
    required this.scanRateController,
    required this.cyclesController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: scanRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Scan Rate',
              suffixText: 'mV/s',
              border: OutlineInputBorder(),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: TextField(
            controller: cyclesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cycles',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
