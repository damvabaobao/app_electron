import 'package:flutter/material.dart';

class PotentialInput extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController endController;

  const PotentialInput({
    super.key,
    required this.startController,
    required this.endController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Potential',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: startController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Start',
                  suffixText: 'V',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: endController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'End',
                  suffixText: 'V',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
