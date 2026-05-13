import 'package:evently_c18_dokki/core/l10n/app_localizations.dart';
import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/core/theme/app_theme.dart';
import 'package:evently_c18_dokki/core/utils/shared_prefernces_keys.dart';
import 'package:evently_c18_dokki/ui/add_event/add_event_screen.dart';
import 'package:evently_c18_dokki/ui/app_setup/app_setup_screen.dart';
import 'package:evently_c18_dokki/ui/edit_event/edit_event_screen.dart';
import 'package:evently_c18_dokki/ui/event_details/event_details_screen.dart';
import 'package:evently_c18_dokki/ui/home/home_screen.dart';
import 'package:evently_c18_dokki/ui/login/login_screen.dart';
import 'package:evently_c18_dokki/ui/onboarding/onboarding_screen.dart';
import 'package:evently_c18_dokki/ui/signup/signup_screen.dart';
import 'package:evently_c18_dokki/ui/splash/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppConfigProvider provider;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return AppConfigProvider();
      },
      child: Consumer<AppConfigProvider>(
        builder: (context, provider, _) {
          this.provider = provider;
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(provider.local),
            themeMode: provider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => SplashScreen(),
              AppSetupScreen.routeName: (_) => AppSetupScreen(),
              LoginScreen.routeName: (_) => LoginScreen(),
              SignupScreen.routeName: (_) => SignupScreen(),
              HomeScreen.routeName: (_) => HomeScreen(),
              OnboardingScreen.routeName: (_) => OnboardingScreen(),
              AddEventScreen.routeName: (_) => const AddEventScreen(),
              EventDetailsScreen.routeName: (_) => const EventDetailsScreen(),
              EditEventScreen.routeName: (_) => const EditEventScreen(),
            },
          );
        },
      ),
    );
  }

  Future<void> init() async {
    final pref = await SharedPreferences.getInstance();
    var locale = pref.getString(SharedPreferencesKeys.locale.name) ?? "en";
    var isDark = pref.getBool(SharedPreferencesKeys.isDark.name) ?? false;

    provider.changeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
    provider.changeLocal(locale);
  }
}