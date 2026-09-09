import 'package:flutter/material.dart';

import '../../models/measurement_config.dart';
import '../../widgets/app_background.dart';
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
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Cài đặt phép đo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMethodCard(),

                const SizedBox(height: 16),

                _buildPotentialCard(),

                const SizedBox(height: 16),

                _buildScanSettingsCard(),

                const SizedBox(height: 16),

                _buildSafetyCard(),

                const SizedBox(height: 24),

                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.science_outlined, title: 'Phương pháp đo'),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _methodButton(
                  method: 'CV',
                  title: 'Cyclic Voltammetry',
                  icon: Icons.show_chart,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _methodButton(
                  method: 'DPV',
                  title: 'Differential Pulse',
                  icon: Icons.stacked_line_chart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodButton({
    required String method,
    required String title,
    required IconData icon,
  }) {
    final selected = selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? Colors.blue.shade100 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.blue.shade700 : Colors.blueGrey,
                size: 25,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              method,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.blue.shade800 : Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.bolt_outlined, title: 'Điện thế'),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: startController,
                  label: 'Điện thế bắt đầu',
                  suffix: 'V',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _numberField(
                  controller: endController,
                  label: 'Điện thế kết thúc',
                  suffix: 'V',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanSettingsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.speed_outlined, title: 'Thông số quét'),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: scanRateController,
                  label: 'Tốc độ quét',
                  suffix: 'mV/s',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _numberField(
                  controller: cyclesController,
                  label: 'Số chu kỳ',
                  suffix: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timer_outlined, color: Colors.orange.shade700),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian dự kiến',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Khoảng 25 giây',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          Icon(Icons.info_outline, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang kiểm tra kết nối thiết bị...'),
                ),
              );
            },
            icon: const Icon(Icons.wifi_find),
            label: const Text(
              'Kiểm tra kết nối',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _startMeasurement,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Bắt đầu phép đo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 23),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade500, width: 1.5),
        ),
      ),
    );
  }

  void _startMeasurement() {
    final config = MeasurementConfig(
      method: selectedMethod,
      startVoltage: double.tryParse(startController.text) ?? -1.2,
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
  }
}
