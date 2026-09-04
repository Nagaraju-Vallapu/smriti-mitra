import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NePatternStrip extends StatelessWidget {
  final double height;

  const NePatternStrip({
    super.key,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<AppColorsExtension>();

    // Safe fallback if the theme extension is not available.
    final colors = extension?.colors ?? AppColors.standard;

    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _NePatternPainter(
            primary: colors.primary,
            amber: colors.accentAmber,
            secondary: colors.secondary,
          ),
        ),
      ),
    );
  }
}

class _NePatternPainter extends CustomPainter {
  final Color primary;
  final Color amber;
  final Color secondary;

  const _NePatternPainter({
    required this.primary,
    required this.amber,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double unit = 18;

    final zigzagPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final zigzagPath = Path();

    double x = 0;
    bool up = true;

    zigzagPath.moveTo(
      0,
      size.height * 0.15,
    );

    while (x < size.width) {
      x += unit / 2;

      zigzagPath.lineTo(
        x,
        up ? size.height * 0.5 : size.height * 0.15,
      );

      up = !up;
    }

    canvas.drawPath(
      zigzagPath,
      zigzagPaint,
    );

    final diamondColors = [
      amber,
      secondary,
      amber,
    ];

    double dx = unit / 2;
    int i = 0;

    while (dx < size.width) {
      final paint = Paint()..color = diamondColors[i % diamondColors.length];

      final cy = size.height * 0.82;

      final path = Path()
        ..moveTo(dx, cy - 4)
        ..lineTo(dx + 4, cy)
        ..lineTo(dx, cy + 4)
        ..lineTo(dx - 4, cy)
        ..close();

      canvas.drawPath(path, paint);

      dx += unit;
      i++;
    }
  }

  @override
  bool shouldRepaint(
    covariant _NePatternPainter oldDelegate,
  ) {
    return oldDelegate.primary != primary ||
        oldDelegate.amber != amber ||
        oldDelegate.secondary != secondary;
  }
}
