import 'package:flutter/material.dart';

/// Same pattern as ElderlyTabController — lets the Caregiver Dashboard's
/// shortcut cards jump to another tab (Performance/Alerts/Patient).
class CaregiverTabController extends InheritedWidget {
  final void Function(int index) goToTab;

  const CaregiverTabController({super.key, required this.goToTab, required super.child});

  static CaregiverTabController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CaregiverTabController>();
  }

  @override
  bool updateShouldNotify(CaregiverTabController oldWidget) => false;
}
