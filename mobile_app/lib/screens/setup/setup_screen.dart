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

  final TextEditingController windowController = TextEditingController(
    text: '11',
  );

  final TextEditingController polynomialController = TextEditingController(
    text: '3',
  );

  String selectedFilter = 'Savitzky-Golay';

  bool baselineCorrection = true;
  bool medianFilter = false;

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    scanRateController.dispose();
    cyclesController.dispose();
    windowController.dispose();
    polynomialController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt tham số - $selectedMethod'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================================================
            // METHOD
            // =========================================================
            _sectionTitle('Phương pháp đo'),

            const SizedBox(height: 10),

            _methodSelector(),

            const SizedBox(height: 20),

            // =========================================================
            // MEASUREMENT PARAMETERS
            // =========================================================
            _sectionTitle('Thông số đo'),

            const SizedBox(height: 12),

            _parameterCard(),

            const SizedBox(height: 16),

            // =========================================================
            // FILTER
            // =========================================================
            _sectionTitle('Bộ lọc nhiễu'),

            const SizedBox(height: 12),

            _filterCard(),

            const SizedBox(height: 16),

            // =========================================================
            // ADVANCED
            // =========================================================
            _advancedCard(),

            const SizedBox(height: 24),

            // =========================================================
            // CONNECTION
            // =========================================================
            _connectionCard(),

            const SizedBox(height: 24),

            // =========================================================
            // START
            // =========================================================
            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: _startMeasurement,

                icon: const Icon(Icons.play_arrow),

                label: const Text(
                  'Bắt đầu đo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // ===============================================================
  // METHOD SELECTOR
  // ===============================================================

  Widget _methodSelector() {
    final methods = ['CV', 'SWV', 'LSV', 'DPV', 'ASV', 'CA', 'EIS'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,

      children: methods.map((method) {
        final selected = selectedMethod == method;

        return ChoiceChip(
          label: Text(method),

          selected: selected,

          onSelected: (_) {
            setState(() {
              selectedMethod = method;
            });
          },
        );
      }).toList(),
    );
  }

  // ===============================================================
  // PARAMETER CARD
  // ===============================================================

  Widget _parameterCard() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            _numberField(
              controller: startController,
              label: 'Điện thế bắt đầu',
              suffix: 'V',
              signed: true,
            ),

            const SizedBox(height: 14),

            _numberField(
              controller: endController,
              label: 'Điện thế kết thúc',
              suffix: 'V',
              signed: true,
            ),

            const SizedBox(height: 14),

            _numberField(
              controller: scanRateController,
              label: 'Tốc độ quét',
              suffix: 'mV/s',
            ),

            const SizedBox(height: 14),

            _numberField(
              controller: cyclesController,
              label: 'Số chu kỳ',
              suffix: '',
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // FILTER CARD
  // ===============================================================

  Widget _filterCard() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Loại bộ lọc',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: selectedFilter,

              decoration: const InputDecoration(border: OutlineInputBorder()),

              items: const [
                DropdownMenuItem(
                  value: 'Savitzky-Golay',
                  child: Text('Savitzky-Golay'),
                ),

                DropdownMenuItem(
                  value: 'Butterworth',
                  child: Text('Butterworth'),
                ),

                DropdownMenuItem(value: 'Median', child: Text('Median')),

                DropdownMenuItem(value: 'None', child: Text('Không lọc')),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 14),

            _numberField(
              controller: windowController,
              label: 'Cửa sổ (window size)',
              suffix: '',
            ),

            const SizedBox(height: 14),

            _numberField(
              controller: polynomialController,
              label: 'Bậc đa thức (polynomial order)',
              suffix: '',
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ADVANCED CARD
  // ===============================================================

  Widget _advancedCard() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: ExpansionTile(
        title: const Text(
          'Tùy chọn nâng cao',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        children: [
          SwitchListTile(
            title: const Text('Baseline correction'),
            value: baselineCorrection,

            onChanged: (value) {
              setState(() {
                baselineCorrection = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Median filter'),
            value: medianFilter,

            onChanged: (value) {
              setState(() {
                medianFilter = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CONNECTION CARD
  // ===============================================================

  Widget _connectionCard() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,

              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                'Raspberry Pi / thiết bị đo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            Text(
              'Đã kết nối',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // NUMBER FIELD
  // ===============================================================

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    bool signed = false,
  }) {
    return TextField(
      controller: controller,

      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: signed,
      ),

      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ===============================================================
  // START MEASUREMENT
  // ===============================================================

  void _startMeasurement() {
    final config = MeasurementConfig(
      method: selectedMethod,

      startVoltage: double.tryParse(startController.text) ?? -1.2,

      endVoltage: double.tryParse(endController.text) ?? 1.2,

      scanRate: double.tryParse(scanRateController.text) ?? 100,

      cycles: int.tryParse(cyclesController.text) ?? 2,

      filterType: selectedFilter,

      windowSize: int.tryParse(windowController.text) ?? 11,

      polynomialOrder: int.tryParse(polynomialController.text) ?? 3,

      baselineCorrection: baselineCorrection,

      medianFilter: medianFilter,
    );

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => MeasurementScreen(config: config),
      ),
    );
  }
}
