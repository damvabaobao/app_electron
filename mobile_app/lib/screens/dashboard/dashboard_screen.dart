import 'package:flutter/material.dart';

import 'widgets/dashboard_appbar.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/pi_status.dart';
import 'widgets/start_measurement_button.dart';

import '../../widgets/device_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardAppBar(),

      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            children: [
              PiStatus(),

              SizedBox(height: 16),

              DeviceStatusCard(),

              SizedBox(height: 20),

              StartMeasurementButton(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const DashboardBottomNav(),
    );
  }
}
