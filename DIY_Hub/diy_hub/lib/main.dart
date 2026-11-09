// lib/main.dart
// App entry point. Shows the splash screen while the saved onboarding state
// loads, then routes to Onboarding (first launch) or Home.
//
// The app is LIGHT-ONLY: there is no dark theme. ThemeController is kept so
// the old Settings screen still compiles, but changing the mode does nothing.
// (The Settings restyle in a later phase removes that UI entirely.)

import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/progress_service.dart';

void main() {
  runApp(const MyApp());
}

/// Lets descendant widgets read the theme mode and request changes, without
/// needing Provider/Riverpod/Bloc. Kept for backwards compatibility only.
class ThemeController extends InheritedWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;

  const ThemeController({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(controller != null, 'ThemeController not found in widget tree');
    return controller!;
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) =>
      themeMode != oldWidget.themeMode;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Minimum time the splash stays visible so it doesn't just flash.
  static const Duration _minSplash = Duration(milliseconds: 900);

  final _progressService = ProgressService();

  bool _onboardingComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final results = await Future.wait<dynamic>([
      _progressService.isOnboardingComplete(),
      Future<void>.delayed(_minSplash),
    ]);
    if (!mounted) return;
    setState(() {
      _onboardingComplete = results[0] as bool;
      _loading = false;
    });
  }

  /// No-op: the app is light-only.
  void _ignoreThemeChange(ThemeMode mode) {}

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      themeMode: ThemeMode.light,
      setThemeMode: _ignoreThemeChange,
      child: MaterialApp(
        title: 'DIYHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: _loading
            ? const SplashScreen()
            : (_onboardingComplete
                ? const HomeScreen()
                : const OnboardingScreen()),
      ),
    );
  }
}
