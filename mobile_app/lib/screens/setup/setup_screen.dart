import 'package:flutter/material.dart';
import '../../models/measurement_config.dart';
import '../measurement/measurement_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String selectedMethod = 'CV';

  final TextEditingController startController = TextEditingController(
    text: '-1.2',
  );

  final TextEditingController endController = TextEditingController(
    text: '1.2',
  );

  final TextEditingController scanRateController = TextEditingController(
    text: '100',
  );

  final TextEditingController cyclesController = TextEditingController(
    text: '2',
  );

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    scanRateController.dispose();
    cyclesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cấu hình phép đo'), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phương pháp đo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('CV'),
                    selected: selectedMethod == 'CV',
                    onSelected: (_) {
                      setState(() {
                        selectedMethod = 'CV';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('DPV'),
                    selected: selectedMethod == 'DPV',
                    onSelected: (_) {
                      setState(() {
                        selectedMethod = 'DPV';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Potential',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 25),

            const Text(
              'Scan Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: scanRateController,
                    keyboardType: TextInputType.number,
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
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Safety',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text('Estimated Time: 25 s'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Kiểm tra kết nối'),
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: () {
                    final config = MeasurementConfig(
                      method: selectedMethod,
                      startVoltage:
                          double.tryParse(startController.text) ?? -1.2,
                      endVoltage: double.tryParse(endController.text) ?? 1.2,
                      scanRate: double.tryParse(scanRateController.text) ?? 100,
                      cycles: int.tryParse(cyclesController.text) ?? 2,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeasurementScreen(config: config),
                      ),
                    );
                  },
                  child: const Text('Bắt đầu phép đo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
