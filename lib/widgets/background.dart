import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/image.jpg",
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(child: Container(color: Colors.black26)),

        child,
      ],
    );
  }
}
