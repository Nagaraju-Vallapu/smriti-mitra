import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../navigation/app_state.dart';
import '../../services/voice_service.dart';
import '../../widgets/voice_assistant_sheet.dart';
import 'elderly_home_screen.dart';
import 'elderly_tab_controller.dart';
import 'games/games_list_screen.dart';
import 'progress_screen.dart';
import 'reminders/reminders_screen.dart';
import 'settings_screen.dart';

/// Bottom-nav shell for the five required Elderly sections: Home, Games,
/// Reminders, Progress, Settings. Each tab keeps its own state via
/// IndexedStack so switching tabs never loses in-progress navigation
/// (e.g. mid-game screens stay mounted underneath, though games commit
/// their own back-to-list navigation on completion).
class ElderlyShell extends StatefulWidget {
  const ElderlyShell({super.key});

  @override
  State<ElderlyShell> createState() => _ElderlyShellState();
}

class _ElderlyShellState extends State<ElderlyShell> {
  int _index = 0;

  final _pages = const [
    ElderlyHomeScreen(),
    GamesListScreen(),
    RemindersScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  void _handleVoiceCommand(String commandKey) {
    switch (commandKey) {
      case VoiceCommandInterpreter.goHome:
        setState(() => _index = 0);
        break;
      case VoiceCommandInterpreter.openGames:
        setState(() => _index = 1);
        break;
      case VoiceCommandInterpreter.openReminders:
        setState(() => _index = 2);
        break;
      case VoiceCommandInterpreter.openProgress:
        setState(() => _index = 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final voiceEnabled = context.watch<AppState>().accessibility.voiceAssistanceEnabled;

    return Scaffold(
      body: ElderlyTabController(
        goToTab: (i) => setState(() => _index = i),
        child: IndexedStack(index: _index, children: _pages),
      ),
      floatingActionButton: voiceEnabled
          ? FloatingActionButton(
              heroTag: 'elderly-voice-fab',
              onPressed: () => showVoiceAssistantSheet(context, onCommand: _handleVoiceCommand),
              child: const Icon(Icons.mic),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t('elderlyHome_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.extension), label: t('elderlyHome_games')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.alarm), label: t('elderlyHome_reminders')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.show_chart), label: t('elderlyHome_progress')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings), label: t('elderlyHome_settings')),
        ],
      ),
    );
  }
}
