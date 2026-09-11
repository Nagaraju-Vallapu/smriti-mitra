import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A soft, rounded, pastel-coloured square used to present an icon or
/// emoji glyph — the colourful tile look used throughout the reference
/// UI (feature grids, activity chips, list-row leading icons). Purely
/// presentational; carries no logic of its own.
class IconTile extends StatelessWidget {
  final Color background;
  final Color foreground;
  final IconData? icon;
  final String? emoji;
  final double size;

  const IconTile({
    super.key,
    required this.background,
    required this.foreground,
    this.icon,
    this.emoji,
    this.size = 52,
  }) : assert(icon != null || emoji != null, 'Provide either icon or emoji');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: icon != null
          ? Icon(icon, color: foreground, size: size * 0.5)
          : Text(emoji!, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}
