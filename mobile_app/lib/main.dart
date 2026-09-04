import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/user_role.dart';
import 'models/accessibility_settings.dart';
import 'navigation/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_wizard_screen.dart';
import 'screens/auth/forgot_password_wizard_screen.dart';
import 'screens/elderly/elderly_shell.dart';
import 'screens/caregiver/caregiver_shell.dart';
import 'screens/language_selection_screen.dart';
import 'screens/user_selection_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/state_widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SmritiMitraApp(),
    ),
  );
}

/// Languages Flutter's own GlobalMaterialLocalizations/
/// GlobalCupertinoLocalizations definitely ship translations for, used
/// ONLY to pick the locale passed to MaterialApp for built-in widget
/// chrome (date/time picker OK/Cancel labels, back-button tooltips,
/// etc.). This is intentionally separate from the app's own content
/// language (AppState.locale, used everywhere via AppLocalizations),
/// which fully supports all five required languages including Assamese
/// and Manipuri. Flutter itself has no built-in translations for those
/// two, so their picker/tooltip chrome falls back to English here —
/// the same "graceful fallback for unsupported platform features"
/// pattern the spec requires for voice/TTS.
const _materialSafeCodes = {'en', 'hi', 'te'};

Locale _materialSafeLocale(Locale appLocale) {
  return _materialSafeCodes.contains(appLocale.languageCode)
      ? appLocale
      : const Locale('en');
}

class SmritiMitraApp extends StatefulWidget {
  const SmritiMitraApp({super.key});

  @override
  State<SmritiMitraApp> createState() => _SmritiMitraAppState();
}

class _SmritiMitraAppState extends State<SmritiMitraApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => const Scaffold(body: LoadingState()),
        },
      );
    }

    final palette = appState.accessibility.highContrast
        ? AppColors.highContrast
        : AppColors.standard;
    final textScale = appState.accessibility.textSize.scaleFactor;

    return MaterialApp(
      title: 'Smriti Mitra',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(colors: palette, textScale: textScale),
      locale: _materialSafeLocale(appState.locale),
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('te')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: appState.role == null
          ? AppRoutes.languageSelect
          : (!appState.isLoggedIn
              ? AppRoutes.login
              : (appState.role == UserRole.elderly
                  ? AppRoutes.elderlyShell
                  : AppRoutes.caregiverShell)),
      routes: {
        AppRoutes.languageSelect: (_) => const LanguageSelectionScreen(),
        AppRoutes.userSelect: (_) => const UserSelectionScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterWizardScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordWizardScreen(),
        AppRoutes.elderlyShell: (_) => const ElderlyShell(),
        AppRoutes.caregiverShell: (_) => const CaregiverShell(),
      },
    );
  }
}
