import 'package:flutter/material.dart';

/// Lets any widget inside the Elderly shell switch tabs (e.g. the Home
/// screen's shortcut cards jumping straight to Games/Reminders/etc.)
/// without threading a callback through every constructor.
class ElderlyTabController extends InheritedWidget {
  final void Function(int index) goToTab;

  const ElderlyTabController({super.key, required this.goToTab, required super.child});

  static ElderlyTabController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElderlyTabController>();
  }

  @override
  bool updateShouldNotify(ElderlyTabController oldWidget) => false;
}
