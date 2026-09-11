import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/accessibility_settings.dart';
import 'models/user_role.dart';
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
import 'widgets/app_background.dart';
import 'widgets/state_widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SmritiMitraApp(),
    ),
  );
}

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
      if (mounted) {
        context.read<AppState>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: LoadingState(),
        ),
        builder: (context, child) {
          return AppBackground(
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    }

    final highContrast = appState.accessibility.highContrast;

    final palette = highContrast
        ? AppColors.highContrast
        : AppColors.standard;

    final textScale =
        appState.accessibility.textSize.scaleFactor;

    late final Widget homeScreen;

    if (appState.role == null) {
      homeScreen = const LanguageSelectionScreen();
    } else if (!appState.isLoggedIn) {
      homeScreen = const LoginScreen();
    } else if (appState.role == UserRole.elderly) {
      homeScreen = const ElderlyShell();
    } else {
      homeScreen = const CaregiverShell();
    }

    final appRoutes = <String, WidgetBuilder>{
      AppRoutes.userSelect:
          (_) => const UserSelectionScreen(),

      AppRoutes.login:
          (_) => const LoginScreen(),

      AppRoutes.register:
          (_) => const RegisterWizardScreen(),

      AppRoutes.forgotPassword:
          (_) => const ForgotPasswordWizardScreen(),

      AppRoutes.elderlyShell:
          (_) => const ElderlyShell(),

      AppRoutes.caregiverShell:
          (_) => const CaregiverShell(),
    };

    // AppRoutes.languageSelect is "/" in this project.
    // "/" is handled by home:, so it must not also be
    // placed inside the routes table.
    if (AppRoutes.languageSelect != '/') {
      appRoutes[AppRoutes.languageSelect] =
          (_) => const LanguageSelectionScreen();
    }

    return MaterialApp(
      title: 'Smriti Mitra',
      debugShowCheckedModeBanner: false,

      theme: buildAppTheme(
        colors: palette,
        textScale: textScale,
      ),

      home: homeScreen,

      builder: (context, child) {
        return AppBackground(
          highContrast: highContrast,
          child: child ?? const SizedBox.shrink(),
        );
      },

      locale: _materialSafeLocale(appState.locale),

      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: appRoutes,
    );
  }
}