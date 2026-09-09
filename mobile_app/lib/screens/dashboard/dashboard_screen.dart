import 'package:flutter/material.dart';

import 'widgets/dashboard_appbar.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/pi_status.dart';
import 'widgets/start_measurement_button.dart';

import '../../widgets/app_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const DashboardAppBar(),

      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo + tên ứng dụng
                const _AppHeader(),

                const SizedBox(height: 18),

                // Trạng thái Raspberry Pi / AD5941
                const PiStatus(),

                const SizedBox(height: 22),

                const Text(
                  'PHÉP ĐO ĐIỆN HÓA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Các phép đo
                const _MeasurementGrid(),

                const SizedBox(height: 20),

                const StartMeasurementButton(),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const DashboardBottomNav(),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/hus_logo.jpg',
          width: 150,
          height: 100,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 6),

        const Text(
          'ỨNG DỤNG ĐO ĐIỆN HÓA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF064A96),
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Khoa Hóa học • Đại học Khoa học Tự nhiên',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF55708C), fontSize: 13),
        ),
      ],
    );
  }
}

class _MeasurementGrid extends StatelessWidget {
  const _MeasurementGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _MeasurementCard(
          icon: Icons.show_chart,
          title: 'CV',
          subtitle: 'Voltammetry vòng',
        ),
        _MeasurementCard(
          icon: Icons.square_foot,
          title: 'SWV',
          subtitle: 'Voltammetry sóng vuông',
        ),
        _MeasurementCard(
          icon: Icons.trending_up,
          title: 'LSV',
          subtitle: 'Voltammetry quét tuyến tính',
        ),
        _MeasurementCard(
          icon: Icons.graphic_eq,
          title: 'DPV',
          subtitle: 'Voltammetry xung vi phân',
        ),
        _MeasurementCard(
          icon: Icons.scatter_plot,
          title: 'ASV',
          subtitle: 'Voltammetry hòa tan anot',
        ),
        _MeasurementCard(
          icon: Icons.timer_outlined,
          title: 'CA',
          subtitle: 'Ampe kế tác dụng',
        ),
        _MeasurementCard(
          icon: Icons.settings_input_component,
          title: 'EIS',
          subtitle: 'Phổ trở kháng điện hóa',
        ),
      ],
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MeasurementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Bước Setup V2 sẽ xử lý việc chọn phép đo.
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF0878E8), size: 27),
              ),

              const SizedBox(height: 7),

              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF064A96),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF60758A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
