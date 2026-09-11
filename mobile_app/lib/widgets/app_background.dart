import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// App-wide background: a soft ivory/tea-garden gradient wash with a
/// faint, repeating geometric weave inspired by Northeast Indian
/// textile borders (Assamese Gamosa, Naga shawls, Mizo Puanchei) —
/// the same diamond-and-chevron language as [NePatternStrip], just
/// stretched across the whole screen at very low opacity so it reads
/// as texture, not decoration that competes with content.
///
/// Mounted once via `MaterialApp(builder: ...)` in main.dart, so every
/// screen shows it automatically without each screen needing its own
/// background handling. Purely visual — no gestures, no semantics,
/// and it steps out of the way entirely in high-contrast mode so
/// accessibility contrast guarantees are never affected.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool highContrast;

  const AppBackground({super.key, required this.child, this.highContrast = false});

  @override
  Widget build(BuildContext context) {
    final colors = highContrast ? AppColors.highContrast : AppColors.standard;

    if (highContrast) {
      // Flat, pure background — no pattern, no gradient — to preserve
      // the maximum-contrast guarantee this mode exists for.
      return ColoredBox(color: colors.background, child: child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.background, colors.surfaceAlt],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _WeavePainter(
                  primary: colors.primary,
                  amber: colors.accentAmber,
                  secondary: colors.secondary,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Paints a very faint, full-screen tile of chevrons and diamonds — the
/// same motif family as the header strip, scaled up and dimmed down so
/// it sits quietly behind text and cards without hurting readability.
class _WeavePainter extends CustomPainter {
  final Color primary;
  final Color amber;
  final Color secondary;

  _WeavePainter({required this.primary, required this.amber, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    const double unit = 46;

    final chevronPaint = Paint()
      ..color = primary.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Rows of gentle chevrons marching down the page.
    for (double y = -unit; y < size.height + unit; y += unit) {
      final path = Path();
      bool up = true;
      double x = -unit;
      path.moveTo(x, y + (up ? 0 : unit * 0.4));
      while (x < size.width + unit) {
        x += unit / 2;
        up = !up;
        path.lineTo(x, y + (up ? 0 : unit * 0.4));
      }
      canvas.drawPath(path, chevronPaint);
    }

    // A sparse scatter of small diamonds between the chevron rows,
    // alternating accent colors like a woven border's accent threads.
    final diamondColors = [amber.withOpacity(0.05), secondary.withOpacity(0.045)];
    int row = 0;
    for (double y = unit * 0.7; y < size.height + unit; y += unit) {
      final offset = (row.isEven) ? 0.0 : unit / 2;
      int i = 0;
      for (double x = offset; x < size.width + unit; x += unit) {
        final paint = Paint()..color = diamondColors[i % diamondColors.length];
        final path = Path()
          ..moveTo(x, y - 7)
          ..lineTo(x + 7, y)
          ..lineTo(x, y + 7)
          ..lineTo(x - 7, y)
          ..close();
        canvas.drawPath(path, paint);
        i++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _WeavePainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.amber != amber ||
        oldDelegate.secondary != secondary;
  }
}
