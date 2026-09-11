import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A thin decorative motif strip inspired by the woven geometric borders
/// found on Northeast Indian textiles (e.g. Assamese Gamosa, Naga shawls,
/// Mizo Puanchei) — a repeating zig-zag with a row of small diamonds.
///
/// Purely decorative (IgnorePointer + no semantics), used as a header
/// accent on first-impression screens so the app visually reads as
/// "made for the Northeast" without touching layout/readability for
/// elderly users. Colors are pulled from the active [AppColorsExtension]
/// so it automatically respects the high-contrast palette too.
class NePatternStrip extends StatelessWidget {
  final double height;

  const NePatternStrip({super.key, this.height = 14});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;
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

  _NePatternPainter({required this.primary, required this.amber, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    const double unit = 18;
    final zigzagPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Zig-zag band across the top third.
    final zigzagPath = Path();
    double x = 0;
    bool up = true;
    zigzagPath.moveTo(0, up ? size.height * 0.15 : size.height * 0.5);
    while (x < size.width) {
      x += unit / 2;
      zigzagPath.lineTo(x, up ? size.height * 0.5 : size.height * 0.15);
      up = !up;
    }
    canvas.drawPath(zigzagPath, zigzagPaint);

    // Row of small alternating diamonds beneath, echoing woven borders.
    final diamondColors = [amber, secondary, amber];
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
  bool shouldRepaint(covariant _NePatternPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.amber != amber ||
        oldDelegate.secondary != secondary;
  }
}
