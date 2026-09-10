import 'package:flutter/material.dart';

import '../../models/measurement_config.dart';
import '../measurement/measurement_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // ============================================================
  // METHOD
  // ============================================================

  String selectedMethod = 'CV';

  final List<String> methods = ['CV', 'LSV', 'SWV', 'DPV', 'ASV', 'CA', 'EIS'];

  // ============================================================
  // COMMON VOLTAGE / SCAN
  // ============================================================

  final startVoltageController = TextEditingController(text: '-200');

  final endVoltageController = TextEditingController(text: '600');

  final stepVoltageController = TextEditingController(text: '10');

  final scanRateController = TextEditingController(text: '100');

  final cyclesController = TextEditingController(text: '1');

  // ============================================================
  // PULSE PARAMETERS
  // ============================================================

  final amplitudeController = TextEditingController(text: '25');

  final pulseWidthController = TextEditingController(text: '50');

  final frequencyController = TextEditingController(text: '10');

  // ============================================================
  // DEPOSITION
  // ============================================================

  bool useDeposition = false;

  final depositionVoltageController = TextEditingController(text: '-500');

  final depositionTimeController = TextEditingController(text: '60000');

  // ============================================================
  // CLEANING
  // ============================================================

  final cleaningVoltageController = TextEditingController(text: '1100');

  final cleaningTimeController = TextEditingController(text: '8000');

  // ============================================================
  // EQUILIBRIUM
  // ============================================================

  final equilibriumVoltageController = TextEditingController(text: '-50');

  final equilibriumTimeController = TextEditingController(text: '10000');

  // ============================================================
  // CHRONOAMPEROMETRY
  // ============================================================

  final appliedVoltageController = TextEditingController(text: '0');

  final timeRunController = TextEditingController(text: '30');

  final timeIntervalController = TextEditingController(text: '100');

  // ============================================================
  // EIS
  // ============================================================

  final startFrequencyController = TextEditingController(text: '1');

  final stopFrequencyController = TextEditingController(text: '100000');

  final sweepPointsController = TextEditingController(text: '50');

  final repeatTimesController = TextEditingController(text: '1');

  // ============================================================
  // FILTER
  // ============================================================

  String selectedFilter = '1/7 (Moving Avg 7pt)';

  // ============================================================
  // CONNECTION
  // ============================================================

  bool deviceConnected = true;

  @override
  void dispose() {
    startVoltageController.dispose();
    endVoltageController.dispose();
    stepVoltageController.dispose();
    scanRateController.dispose();
    cyclesController.dispose();

    amplitudeController.dispose();
    pulseWidthController.dispose();
    frequencyController.dispose();

    depositionVoltageController.dispose();
    depositionTimeController.dispose();

    cleaningVoltageController.dispose();
    cleaningTimeController.dispose();

    equilibriumVoltageController.dispose();
    equilibriumTimeController.dispose();

    appliedVoltageController.dispose();
    timeRunController.dispose();
    timeIntervalController.dispose();

    startFrequencyController.dispose();
    stopFrequencyController.dispose();
    sweepPointsController.dispose();
    repeatTimesController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt phép đo - $selectedMethod'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _sectionTitle('Phương pháp đo'),

            const SizedBox(height: 12),

            _buildMethodSelector(),

            const SizedBox(height: 20),

            _sectionTitle('Thông số phép đo'),

            const SizedBox(height: 12),

            _buildMethodParameters(),

            const SizedBox(height: 20),

            _sectionTitle('Bộ lọc tín hiệu'),

            const SizedBox(height: 12),

            _buildFilterCard(),

            const SizedBox(height: 20),

            _buildConnectionCard(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: _startMeasurement,

                icon: const Icon(Icons.play_arrow),

                label: const Text(
                  'Bắt đầu phép đo',
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // ============================================================
  // METHOD SELECTOR
  // ============================================================

  Widget _buildMethodSelector() {
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

  // ============================================================
  // METHOD PARAMETERS
  // ============================================================

  Widget _buildMethodParameters() {
    switch (selectedMethod) {
      case 'CV':
        return _buildCVParameters();

      case 'LSV':
        return _buildLSVParameters();

      case 'SWV':
        return _buildSWVParameters();

      case 'DPV':
        return _buildDPVParameters();

      case 'ASV':
        return _buildASVParameters();

      case 'CA':
        return _buildCAParameters();

      case 'EIS':
        return _buildEISParameters();

      default:
        return _buildCVParameters();
    }
  }

  // ============================================================
  // CV
  // ============================================================

  Widget _buildCVParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: startVoltageController,
          label: 'Điện thế bắt đầu',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: endVoltageController,
          label: 'Điện thế kết thúc',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: stepVoltageController,
          label: 'Bước điện thế',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: scanRateController,
          label: 'Tốc độ quét',
          suffix: 'mV/s',
        ),

        _numberField(
          controller: cyclesController,
          label: 'Số chu kỳ',
          suffix: '',
        ),
      ],
    );
  }

  // ============================================================
  // LSV
  // ============================================================

  Widget _buildLSVParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: startVoltageController,
          label: 'Điện thế bắt đầu',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: endVoltageController,
          label: 'Điện thế kết thúc',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: stepVoltageController,
          label: 'Bước điện thế',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: scanRateController,
          label: 'Tốc độ quét',
          suffix: 'mV/s',
        ),
      ],
    );
  }

  // ============================================================
  // SWV
  // ============================================================

  Widget _buildSWVParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: startVoltageController,
          label: 'Điện thế bắt đầu',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: endVoltageController,
          label: 'Điện thế kết thúc',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: stepVoltageController,
          label: 'Bước điện thế',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: amplitudeController,
          label: 'Biên độ xung',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: pulseWidthController,
          label: 'Độ rộng xung',
          suffix: 'ms',
        ),

        _numberField(
          controller: frequencyController,
          label: 'Tần số',
          suffix: 'Hz',
        ),
      ],
    );
  }

  // ============================================================
  // DPV
  // ============================================================

  Widget _buildDPVParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: startVoltageController,
          label: 'Điện thế bắt đầu',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: endVoltageController,
          label: 'Điện thế kết thúc',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: stepVoltageController,
          label: 'Bước điện thế',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: amplitudeController,
          label: 'Biên độ xung',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: pulseWidthController,
          label: 'Độ rộng xung',
          suffix: 'ms',
        ),

        _numberField(
          controller: frequencyController,
          label: 'Tần số',
          suffix: 'Hz',
        ),
      ],
    );
  }

  // ============================================================
  // ASV
  // ============================================================

  Widget _buildASVParameters() {
    return Column(
      children: [
        _parameterCard(
          title: 'Quét điện thế',
          children: [
            _numberField(
              controller: startVoltageController,
              label: 'Điện thế bắt đầu',
              suffix: 'mV',
              signed: true,
            ),

            _numberField(
              controller: endVoltageController,
              label: 'Điện thế kết thúc',
              suffix: 'mV',
              signed: true,
            ),

            _numberField(
              controller: stepVoltageController,
              label: 'Bước điện thế',
              suffix: 'mV',
              signed: true,
            ),

            _numberField(
              controller: scanRateController,
              label: 'Tốc độ quét',
              suffix: 'mV/s',
            ),
          ],
        ),

        const SizedBox(height: 14),

        _parameterCard(
          title: 'Deposition',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sử dụng deposition'),

              value: useDeposition,

              onChanged: (value) {
                setState(() {
                  useDeposition = value;
                });
              },
            ),

            if (useDeposition) ...[
              _numberField(
                controller: depositionVoltageController,
                label: 'Điện thế deposition',
                suffix: 'mV',
                signed: true,
              ),

              _numberField(
                controller: depositionTimeController,
                label: 'Thời gian deposition',
                suffix: 'ms',
              ),
            ],
          ],
        ),

        const SizedBox(height: 14),

        _parameterCard(
          title: 'Cleaning',
          children: [
            _numberField(
              controller: cleaningVoltageController,
              label: 'Điện thế cleaning',
              suffix: 'mV',
              signed: true,
            ),

            _numberField(
              controller: cleaningTimeController,
              label: 'Thời gian cleaning',
              suffix: 'ms',
            ),
          ],
        ),

        const SizedBox(height: 14),

        _parameterCard(
          title: 'Equilibrium',
          children: [
            _numberField(
              controller: equilibriumVoltageController,
              label: 'Điện thế equilibrium',
              suffix: 'mV',
              signed: true,
            ),

            _numberField(
              controller: equilibriumTimeController,
              label: 'Thời gian equilibrium',
              suffix: 'ms',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CA
  // ============================================================

  Widget _buildCAParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: appliedVoltageController,
          label: 'Điện thế áp dụng',
          suffix: 'mV',
          signed: true,
        ),

        _numberField(
          controller: timeRunController,
          label: 'Thời gian đo',
          suffix: 's',
        ),

        _numberField(
          controller: timeIntervalController,
          label: 'Khoảng thời gian lấy mẫu',
          suffix: 'ms',
        ),

        _numberField(
          controller: repeatTimesController,
          label: 'Số lần lặp',
          suffix: '',
        ),
      ],
    );
  }

  // ============================================================
  // EIS
  // ============================================================

  Widget _buildEISParameters() {
    return _parameterCard(
      children: [
        _numberField(
          controller: startFrequencyController,
          label: 'Tần số bắt đầu',
          suffix: 'Hz',
        ),

        _numberField(
          controller: stopFrequencyController,
          label: 'Tần số kết thúc',
          suffix: 'Hz',
        ),

        _numberField(
          controller: sweepPointsController,
          label: 'Số điểm quét',
          suffix: '',
        ),

        _numberField(
          controller: repeatTimesController,
          label: 'Số lần lặp',
          suffix: '',
        ),
      ],
    );
  }

  // ============================================================
  // PARAMETER CARD
  // ============================================================

  Widget _parameterCard({String? title, required List<Widget> children}) {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
            ],

            ..._addSpacing(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets) {
    final result = <Widget>[];

    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);

      if (i < widgets.length - 1) {
        result.add(const SizedBox(height: 14));
      }
    }

    return result;
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilterCard() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: DropdownButtonFormField<String>(
          initialValue: selectedFilter,

          decoration: const InputDecoration(
            labelText: 'Phương pháp lọc',
            border: OutlineInputBorder(),
          ),

          items: const [
            DropdownMenuItem(
              value: '1/7 (Moving Avg 7pt)',
              child: Text('Moving Average 7 điểm'),
            ),

            DropdownMenuItem(
              value: 'Savitzky-Golay',
              child: Text('Savitzky-Golay'),
            ),

            DropdownMenuItem(value: 'Butterworth', child: Text('Butterworth')),

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
      ),
    );
  }

  // ============================================================
  // CONNECTION
  // ============================================================

  Widget _buildConnectionCard() {
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

              decoration: BoxDecoration(
                color: deviceConnected ? Colors.green : Colors.red,

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
              deviceConnected ? 'Đã kết nối' : 'Chưa kết nối',

              style: TextStyle(
                color: deviceConnected
                    ? Colors.green.shade700
                    : Colors.red.shade700,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER FIELD
  // ============================================================

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

  // ============================================================
  // START MEASUREMENT
  // ============================================================

  void _startMeasurement() {
    final config = MeasurementConfig(
      method: selectedMethod,

      // ----------------------------------------------------------
      // Voltage / scan
      // ----------------------------------------------------------
      startVoltage: double.tryParse(startVoltageController.text) ?? -200,

      endVoltage: double.tryParse(endVoltageController.text) ?? 600,

      stepVoltage: double.tryParse(stepVoltageController.text) ?? 10,

      scanRate: double.tryParse(scanRateController.text) ?? 100,

      // ----------------------------------------------------------
      // General repeat
      // ----------------------------------------------------------
      cycles: int.tryParse(cyclesController.text) ?? 1,

      // ----------------------------------------------------------
      // Pulse
      // ----------------------------------------------------------
      amplitude: double.tryParse(amplitudeController.text) ?? 25,

      pulseWidth: double.tryParse(pulseWidthController.text) ?? 50,

      frequency: double.tryParse(frequencyController.text) ?? 10,

      // ----------------------------------------------------------
      // Filter
      // ----------------------------------------------------------
      filterType: selectedFilter,

      // ----------------------------------------------------------
      // Deposition
      // ----------------------------------------------------------
      useDeposition: useDeposition,

      depositionVoltage:
          double.tryParse(depositionVoltageController.text) ?? -500,

      depositionTime: int.tryParse(depositionTimeController.text) ?? 60000,

      // ----------------------------------------------------------
      // Cleaning
      // ----------------------------------------------------------
      cleaningVoltage: double.tryParse(cleaningVoltageController.text) ?? 1100,

      cleaningTime: int.tryParse(cleaningTimeController.text) ?? 8000,

      // ----------------------------------------------------------
      // Equilibrium
      // ----------------------------------------------------------
      equilibriumVoltage:
          double.tryParse(equilibriumVoltageController.text) ?? -50,

      equilibriumTime: int.tryParse(equilibriumTimeController.text) ?? 10000,

      // ----------------------------------------------------------
      // Chronoamperometry
      // ----------------------------------------------------------
      timeRun: int.tryParse(timeRunController.text) ?? 30,

      appliedVoltage: double.tryParse(appliedVoltageController.text) ?? 0,

      timeInterval: int.tryParse(timeIntervalController.text) ?? 100,

      // ----------------------------------------------------------
      // EIS
      // ----------------------------------------------------------
      startFrequency: double.tryParse(startFrequencyController.text) ?? 1,

      stopFrequency: double.tryParse(stopFrequencyController.text) ?? 100000,

      sweepPoints: int.tryParse(sweepPointsController.text) ?? 50,

      repeatTimes: int.tryParse(repeatTimesController.text) ?? 1,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeasurementScreen(config: config),
      ),
    );
  }
}
