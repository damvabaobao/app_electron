import 'package:flutter/material.dart';

import '../../setup/setup_screen.dart';
import '../../history/history_screen.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,

      backgroundColor: Colors.white.withValues(alpha: 0.96),

      indicatorColor: const Color(0xFFDCEEFF),

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.science_outlined),
          selectedIcon: Icon(Icons.science),
          label: 'Đo lường',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Lịch sử',
        ),
      ],

      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SetupScreen()),
            );
            break;

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
            break;
        }
      },
    );
  }
}
