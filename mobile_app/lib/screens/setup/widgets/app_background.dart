import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Nen chinh
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FCFF), Color(0xFFEAF5FF)],
            ),
          ),
        ),
        //Logo watermark
        Positioned(
          left: 0,
          right: 0,
          top: 120,
          child: Center(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/hus_logo.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        //Noi dung
        child,
      ],
    );
  }
}
