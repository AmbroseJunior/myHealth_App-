import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/route_names.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

import 'features/demographics/providers/demographics_provider.dart';
import 'features/demographics/screens/demographics_screen.dart';
import 'features/demographics/screens/demographics_form_screen.dart';

import 'features/questionnaires/providers/who5_provider.dart';
import 'features/questionnaires/providers/framingham_provider.dart';
import 'features/questionnaires/providers/findrisc_provider.dart';
import 'features/questionnaires/screens/who5/who5_questionnaire_screen.dart';
import 'features/questionnaires/screens/who5/who5_history_screen.dart';
import 'features/questionnaires/screens/framingham/framingham_form_screen.dart';
import 'features/questionnaires/screens/framingham/framingham_history_screen.dart';
import 'features/questionnaires/screens/findrisc/findrisc_form_screen.dart';
import 'features/questionnaires/screens/findrisc/findrisc_history_screen.dart';

import 'features/allergies/providers/allergies_provider.dart';
import 'features/allergies/screens/allergies_screen.dart';
import 'features/allergies/screens/allergy_form_screen.dart';

import 'features/medications/providers/medications_provider.dart';
import 'features/medications/screens/medications_screen.dart';
import 'features/medications/screens/medication_form_screen.dart';
import 'features/medications/screens/medication_history_screen.dart';

import 'features/problems/providers/problems_provider.dart';
import 'features/problems/screens/problems_screen.dart';
import 'features/problems/screens/problem_form_screen.dart';

import 'features/calendar/providers/calendar_provider.dart';
import 'features/calendar/screens/calendar_screen.dart';

import 'features/settings/providers/locale_provider.dart';
import 'features/settings/screens/settings_screen.dart';

class MyHealthApp extends StatelessWidget {
  const MyHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DemographicsProvider()),
        ChangeNotifierProvider(create: (_) => Who5Provider()),
        ChangeNotifierProvider(create: (_) => FraminghamProvider()),
        ChangeNotifierProvider(create: (_) => FindriscProvider()),
        ChangeNotifierProvider(create: (_) => AllergiesProvider()),
        ChangeNotifierProvider(create: (_) => MedicationsProvider()),
        ChangeNotifierProvider(create: (_) => ProblemsProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (_, localeProv, __) => MaterialApp(
          title: 'myHealth',
          debugShowCheckedModeBanner: false,
          locale: localeProv.locale,
          supportedLocales: const [Locale('en'), Locale('el')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: AppColors.colorScheme,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          initialRoute: RouteNames.login,
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RouteNames.demographics:
        return MaterialPageRoute(builder: (_) => const DemographicsScreen());
      case RouteNames.demographicsEdit:
        return MaterialPageRoute(builder: (_) => const DemographicsFormScreen());
      case RouteNames.who5:
        return MaterialPageRoute(builder: (_) => const Who5QuestionnaireScreen());
      case RouteNames.who5History:
        return MaterialPageRoute(builder: (_) => const Who5HistoryScreen());
      case RouteNames.framingham:
        return MaterialPageRoute(builder: (_) => const FraminghamFormScreen());
      case RouteNames.framinghamHistory:
        return MaterialPageRoute(builder: (_) => const FraminghamHistoryScreen());
      case RouteNames.findrisc:
        return MaterialPageRoute(builder: (_) => const FindriscFormScreen());
      case RouteNames.findriscHistory:
        return MaterialPageRoute(builder: (_) => const FindriscHistoryScreen());
      case RouteNames.allergies:
        return MaterialPageRoute(builder: (_) => const AllergiesScreen());
      case RouteNames.allergyForm:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AllergyFormScreen());
      case RouteNames.medications:
        return MaterialPageRoute(builder: (_) => const MedicationsScreen());
      case RouteNames.medicationForm:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MedicationFormScreen());
      case RouteNames.medicationHistory:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MedicationHistoryScreen());
      case RouteNames.problems:
        return MaterialPageRoute(builder: (_) => const ProblemsScreen());
      case RouteNames.problemForm:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ProblemFormScreen());
      case RouteNames.calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
