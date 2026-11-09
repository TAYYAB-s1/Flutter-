// lib/screens/splash_screen.dart
// Shown while the app loads its saved onboarding state. Cream screen with a
// yellow bolt logo block, wordmark, tagline, a chunky block loading bar and
// a hazard strip at the bottom.

import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../widgets/hazard_strip.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int _blockCount = 5;

  Timer? _timer;
  int _filled = 1;

  @override
  void initState() {
    super.initState();
    // Advance the loading blocks 1..5, then loop.
    _timer = Timer.periodic(const Duration(milliseconds: 280), (_) {
      if (!mounted) return;
      setState(() => _filled = _filled >= _blockCount ? 1 : _filled + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo block: yellow square, bolt, hard shadow.
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.actionYellow,
                          border: Border.fromBorderSide(AppTheme.border),
                          boxShadow: AppTheme.hardShadow(offset: 6),
                        ),
                        child: const Icon(Icons.bolt,
                            size: 54, color: AppColors.ink),
                      ),
                      const SizedBox(height: 28),
                      Text('DIYHUB',
                          style: AppText.display(size: 44, letterSpacing: 1)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          border: Border.fromBorderSide(AppTheme.tagBorder),
                        ),
                        child: Text(
                          'BUILD. LEARN. LEVEL UP.',
                          style: AppText.tag(size: 12),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Chunky block loading bar.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_blockCount, (i) {
                          final filled = i < _filled;
                          return Container(
                            width: 26,
                            height: 26,
                            margin: EdgeInsets.only(
                                right: i == _blockCount - 1 ? 0 : 8),
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.actionYellow
                                  : AppColors.white,
                              border: const Border.fromBorderSide(
                                  AppTheme.tagBorder),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text('LOADING',
                          style: AppText.tag(size: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              'v1.0.0 · works offline',
              style: AppText.tag(
                  size: 11, color: AppColors.muted, weight: FontWeight.w400),
            ),
            const SizedBox(height: 14),
            const HazardStrip(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
