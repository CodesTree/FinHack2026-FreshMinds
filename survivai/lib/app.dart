import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/consent_screen.dart';
import 'features/dashboard/screens/home_screen.dart';
import 'features/emergency/screens/emergency_screen.dart';
import 'features/ecl/screens/ecl_apply_screen.dart';
import 'features/ecl/screens/ecl_consent_screen.dart';
import 'features/ecl/screens/ecl_processing_screen.dart';
import 'features/ecl/screens/ecl_result_screen.dart';
import 'features/card/screens/mcc_card_screen.dart';
import 'features/transactions/screens/transactions_screen.dart';
import 'features/nudges/screens/nudges_screen.dart';
import 'features/settings/screens/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/onboarding/consent', builder: (_, __) => const ConsentScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/emergency', builder: (_, __) => const EmergencyScreen()),
    GoRoute(path: '/ecl/apply', builder: (_, __) => const EclApplyScreen()),
    GoRoute(path: '/ecl/consent', builder: (_, __) => const EclConsentScreen()),
    GoRoute(path: '/ecl/processing', builder: (_, __) => const EclProcessingScreen()),
    GoRoute(path: '/ecl/result', builder: (_, __) => const EclResultScreen()),
    GoRoute(path: '/card', builder: (_, __) => const MccCardScreen()),
    GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen()),
    GoRoute(path: '/nudges', builder: (_, __) => const NudgesScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

class SurvivAIApp extends StatelessWidget {
  const SurvivAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp.router(
        title: 'SurvivAI',
        theme: AppTheme.theme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
