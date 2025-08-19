import 'package:flutter/material.dart';

/// A widget that paints the provided image behind its [child].  Use this
/// widget to give every screen a consistent background image.  The
/// decoration will expand to fill the available space.
class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_custom.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}