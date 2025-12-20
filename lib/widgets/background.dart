import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset("assets/images/image.jpg", fit: BoxFit.cover),
        ),

        // Dark overlay using predefined low-opacity color
        Positioned.fill(
          child: Container(
            color: Colors.black26, // light dark overlay without withOpacity
          ),
        ),

        // Page content
        child,
      ],
    );
  }
}
