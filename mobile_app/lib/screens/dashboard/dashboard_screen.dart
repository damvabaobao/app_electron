import 'package:flutter/material.dart';

import 'widgets/dashboard_appbar.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/pi_status.dart';
import 'widgets/start_measurement_button.dart';

import '../../widgets/device_status_card.dart';
import '../../widgets/app_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: const DashboardAppBar(),

      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcome(),

                const SizedBox(height: 18),

                const PiStatus(),

                const SizedBox(height: 14),

                const DeviceStatusCard(),

                const SizedBox(height: 20),

                _buildMeasurementSection(),

                const SizedBox(height: 12),

                const StartMeasurementButton(),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const DashboardBottomNav(),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ỨNG DỤNG ĐO ĐIỆN HÓA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Khoa Vật lý • Đại học Khoa học Tự nhiên',
          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
        ),
      ],
    );
  }

  Widget _buildMeasurementSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.science_outlined,
              color: Colors.blue.shade700,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phép đo điện hóa',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4),

                Text(
                  'Thiết lập và bắt đầu phép đo mới',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
