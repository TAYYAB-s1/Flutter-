// lib/main.dart
// App entry point. Loads the saved theme mode and onboarding status before
// building the MaterialApp, and exposes a ThemeController InheritedWidget
// so any screen (e.g. Settings, built in a later phase) can change the
// theme mode with `ThemeController.of(context).setThemeMode(mode)` —
// no external state management package needed.

import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/progress_service.dart';

void main() {
  runApp(const MyApp());
}

/// Lets descendant widgets read the current theme mode and request changes,
/// without needing Provider/Riverpod/Bloc.
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
    final controller = context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(controller != null, 'ThemeController not found in widget tree');
    return controller!;
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) => themeMode != oldWidget.themeMode;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _progressService = ProgressService();

  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final mode = await _progressService.getThemeMode();
    final onboarded = await _progressService.isOnboardingComplete();
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
      _onboardingComplete = onboarded;
      _loading = false;
    });
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _progressService.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ThemeController(
      themeMode: _themeMode,
      setThemeMode: _updateThemeMode,
      child: MaterialApp(
        title: 'DIYHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: _onboardingComplete ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }
}