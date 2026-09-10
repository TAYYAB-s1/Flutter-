// lib/main.dart

import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme + seed color before app starts
  final savedTheme = await StorageService.instance.loadThemeMode();
  final savedColor = await StorageService.instance.loadSeedColor();

  runApp(ConvertItApp(
    initialThemeMode: savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
    initialSeedColor: savedColor != null ? Color(savedColor) : AppColors.primary,
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Root App Widget
// ─────────────────────────────────────────────────────────────────────────────

class ConvertItApp extends StatefulWidget {
  const ConvertItApp({
    super.key,
    this.initialThemeMode = ThemeMode.dark,
    this.initialSeedColor = AppColors.primary,
  });

  final ThemeMode initialThemeMode;
  final Color     initialSeedColor;

  @override
  State<ConvertItApp> createState() => _ConvertItAppState();
}

class _ConvertItAppState extends State<ConvertItApp> {
  late ThemeMode _themeMode;
  late Color     _seedColor;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _seedColor = widget.initialSeedColor;
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    StorageService.instance.saveThemeMode(
        mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void _setSeedColor(Color color) {
    setState(() => _seedColor = color);
    StorageService.instance.saveSeedColor(color.value);
  }

  bool get _isDark =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding
              .instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title                   : 'ConvertIt',
      debugShowCheckedModeBanner: false,
      themeMode               : _themeMode,
      theme                   : AppTheme.light(seedColor: _seedColor),
      darkTheme               : AppTheme.dark(seedColor: _seedColor),
      home: _MainShell(
        isDark          : _isDark,
        seedColor       : _seedColor,
        onThemeToggle   : () => _setThemeMode(
            _isDark ? ThemeMode.light : ThemeMode.dark),
        onSeedColorChange: _setSeedColor,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MainShell — bottom nav + IndexedStack
// ─────────────────────────────────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell({
    required this.isDark,
    required this.seedColor,
    required this.onThemeToggle,
    required this.onSeedColorChange,
  });

  final bool                isDark;
  final Color               seedColor;
  final VoidCallback        onThemeToggle;
  final ValueChanged<Color> onSeedColorChange;

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Built inside build() so screens always receive fresh props
    final screens = [
      HomeScreen(
        isDark       : widget.isDark,
        onThemeToggle: widget.onThemeToggle,
      ),
      const HistoryScreen(),
      SettingsScreen(
        isDark           : widget.isDark,
        seedColor        : widget.seedColor,
        onThemeToggle    : widget.onThemeToggle,
        onSeedColorChange: widget.onSeedColorChange,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index   : _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap       : (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon      : Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label     : 'Home',
          ),
          BottomNavigationBarItem(
            icon      : Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label     : 'History',
          ),
          BottomNavigationBarItem(
            icon      : Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label     : 'Settings',
          ),
        ],
      ),
    );
  }
}