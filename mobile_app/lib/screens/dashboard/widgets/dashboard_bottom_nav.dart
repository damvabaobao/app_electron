import 'package:flutter/material.dart';

import '../../setup/setup_screen.dart';
import '../../history/history_screen.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Đo lường'),

        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
      ],

      onTap: (index) {
        switch (index) {
          case 0:
            // Đang ở Dashboard
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
