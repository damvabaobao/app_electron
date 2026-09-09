import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,

      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF064A96)),
        onPressed: () {},
      ),

      title: const Text(
        'ElectroChem AI',
        style: TextStyle(
          color: Color(0xFF064A96),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      centerTitle: true,

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF064A96)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
