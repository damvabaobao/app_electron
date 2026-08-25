import 'package:flutter/material.dart';

class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tieu de
            const Text(
              'Device Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            // Trang thai thiet bi
            Row(
              children: [
                Image.asset(
                  'assets/images/device_icon.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.memory, size: 45);
                  },
                ),

                const SizedBox(width: 12),
                const Text(
                  'Rasoberry Pi: Online',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // CPU
            _buildStatusRow(icon: Icons.memory, label: 'CPU', value: '37%'),
            const SizedBox(height: 10),
            _buildStatusRow(icon: Icons.storage, label: 'RAM', value: '41%'),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.sd_sharp,
              label: 'Storage',
              value: '12 GB Free',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
