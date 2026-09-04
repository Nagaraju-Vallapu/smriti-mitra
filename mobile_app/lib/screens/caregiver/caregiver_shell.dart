import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../navigation/app_state.dart';
import '../../services/voice_service.dart';
import '../../widgets/voice_assistant_sheet.dart';
import 'caregiver_alerts_screen.dart';
import 'caregiver_dashboard_screen.dart';
import 'caregiver_patient_screen.dart';
import 'caregiver_performance_screen.dart';
import 'caregiver_settings_screen.dart';
import 'caregiver_tab_controller.dart';

/// Bottom-nav shell for the five required Caregiver sections: Dashboard,
/// Performance, Alerts, Patient, Settings.
class CaregiverShell extends StatefulWidget {
  const CaregiverShell({super.key});

  @override
  State<CaregiverShell> createState() => _CaregiverShellState();
}

class _CaregiverShellState extends State<CaregiverShell> {
  int _index = 0;

  final _pages = const [
    CaregiverDashboardScreen(),
    CaregiverPerformanceScreen(),
    CaregiverAlertsScreen(),
    CaregiverPatientScreen(),
    SettingsScreen(),
  ];

  void _handleVoiceCommand(String commandKey) {
    switch (commandKey) {
      case VoiceCommandInterpreter.goHome:
        setState(() => _index = 0);
        break;
      case VoiceCommandInterpreter.openProgress:
        setState(() => _index = 1);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final voiceEnabled = context.watch<AppState>().accessibility.voiceAssistanceEnabled;

    return Scaffold(
      body: CaregiverTabController(
        goToTab: (i) => setState(() => _index = i),
        child: IndexedStack(index: _index, children: _pages),
      ),
      floatingActionButton: voiceEnabled
          ? FloatingActionButton(
              heroTag: 'caregiver-voice-fab',
              onPressed: () => showVoiceAssistantSheet(context, onCommand: _handleVoiceCommand),
              child: const Icon(Icons.mic),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: t('caregiverDashboard_title')),
          BottomNavigationBarItem(icon: const Icon(Icons.insights), label: t('caregiverDashboard_performance')),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: t('caregiverDashboard_alerts')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: t('caregiverDashboard_patient')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t('caregiverDashboard_settings')),
        ],
      ),
    );
  }
}
