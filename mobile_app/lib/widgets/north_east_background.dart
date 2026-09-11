import 'package:flutter/material.dart';

class NorthEastBackground extends StatelessWidget {
  final Widget child;

  const NorthEastBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/north_east_background.png',
          fit: BoxFit.cover,
        ),

        // Soft white overlay so elderly users can read the content easily.
        Container(
          color: Colors.white.withValues(alpha: 0.78),
        ),

        SafeArea(
          child: child,
        ),
      ],
    );
  }
}