import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ne_pattern_strip.dart';

/// Wraps any screen body with the app-wide Northeast-India visual
/// identity: a soft cream-to-teal gradient, layered hill/mountain
/// silhouettes, a bamboo-and-leaf motif in a corner, a few small floral
/// accents, and woven-textile pattern strips top and bottom.
///
/// This widget only ever adds a decorative *layer behind* [child] — it
/// never changes sizing, scrolling, or interaction, so it is safe to
/// drop into any existing Scaffold's `body:` without touching layout,
/// state, or navigation logic.
///
/// When the active palette is [AppColors.highContrast] (i.e. the user
/// has "High Contrast" turned on in Settings), all decorative art is
/// suppressed and a flat background is used instead, so contrast is
/// never compromised for the people who rely on that setting.
class NeBackground extends StatelessWidget {
  final Widget child;
  final bool showPatternStrips;

  const NeBackground({super.key, required this.child, this.showPatternStrips = true});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()?.colors ?? AppColors.standard;
    final isHighContrast = colors.background == AppColors.highContrast.background &&
        colors.primary == AppColors.highContrast.primary;

    if (isHighContrast) {
      return Container(color: colors.background, child: child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: colors.background),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _NeScenicPainter(colors: colors)),
          ),
        ),
        if (showPatternStrips)
          const Positioned(top: 0, left: 0, right: 0, child: NePatternStrip(height: 10)),
        if (showPatternStrips)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.flip(flipY: true, child: const NePatternStrip(height: 8)),
          ),
        child,
      ],
    );
  }
}

class _NeScenicPainter extends CustomPainter {
  final AppColors colors;
  _NeScenicPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft base wash: cream near the top fading to a pale teal near the
    // bottom, evoking early-morning hill light without competing with
    // foreground text/cards.
    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.background,
          Color.lerp(colors.background, colors.primaryLight, 0.55)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), wash);

    _paintMountains(canvas, w, h);
    _paintBamboo(canvas, w, h);
    _paintFlowers(canvas, w, h);
  }

  void _paintMountains(Canvas canvas, double w, double h) {
    final baseY = h * 0.86;

    void ridge(double amplitude, double yOffset, Color color, double opacity) {
      final path = Path()..moveTo(0, baseY + yOffset);
      path.quadraticBezierTo(
          w * 0.18, baseY + yOffset - amplitude, w * 0.38, baseY + yOffset - amplitude * 0.35);
      path.quadraticBezierTo(
          w * 0.55, baseY + yOffset + amplitude * 0.25, w * 0.72, baseY + yOffset - amplitude * 0.8);
      path.quadraticBezierTo(w * 0.88, baseY + yOffset - amplitude * 0.2, w, baseY + yOffset - amplitude * 0.5);
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
    }

    ridge(h * 0.05, 10, colors.secondary, 0.10);
    ridge(h * 0.065, 34, colors.primary, 0.16);
    ridge(h * 0.045, 58, colors.primaryDark, 0.14);
  }

  void _paintBamboo(Canvas canvas, double w, double h) {
    final stalkPaint = Paint()
      ..color = colors.primary.withOpacity(0.16)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final nodePaint = Paint()
      ..color = colors.primaryDark.withOpacity(0.16)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()..color = colors.primary.withOpacity(0.14);

    // Two gently curved stalks tucked in the top-left corner.
    for (final dx in [w * 0.02, w * 0.09]) {
      final path = Path()
        ..moveTo(dx, -10)
        ..quadraticBezierTo(dx + 18, h * 0.10, dx + 4, h * 0.22);
      canvas.drawPath(path, stalkPaint);
      for (final ny in [h * 0.05, h * 0.11, h * 0.17]) {
        canvas.drawLine(Offset(dx - 6, ny), Offset(dx + 10, ny), nodePaint);
      }
    }

    // Leaf clusters around the stalks.
    void leaf(Offset origin, double angle, double length) {
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.5, -length * 0.22, length, 0)
        ..quadraticBezierTo(length * 0.5, length * 0.22, 0, 0);
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }

    leaf(Offset(w * 0.05, h * 0.06), -0.5, 46);
    leaf(Offset(w * 0.10, h * 0.09), 0.35, 40);
    leaf(Offset(w * 0.03, h * 0.14), -0.15, 38);
    leaf(Offset(w * 0.11, h * 0.16), 0.7, 34);
  }

  void _paintFlowers(Canvas canvas, double w, double h) {
    void bloom(Offset center, double r, Color petal, Color core) {
      final petalPaint = Paint()..color = petal.withOpacity(0.5);
      for (int i = 0; i < 5; i++) {
        final angle = (i / 5) * math.pi * 2;
        final px = center.dx + r * 0.9 * math.cos(angle);
        final py = center.dy + r * 0.9 * math.sin(angle);
        canvas.drawCircle(Offset(px, py), r * 0.55, petalPaint);
      }
      canvas.drawCircle(center, r * 0.45, Paint()..color = core.withOpacity(0.55));
    }

    bloom(Offset(w * 0.90, h * 0.05), 10, colors.accentRose, colors.accentPeach);
    bloom(Offset(w * 0.82, h * 0.10), 7, colors.accentPeach, colors.accentAmber);
    bloom(Offset(w * 0.08, h * 0.24), 8, colors.accentRose, colors.accentAmber);
  }

  @override
  bool shouldRepaint(covariant _NeScenicPainter oldDelegate) => oldDelegate.colors != colors;
}
