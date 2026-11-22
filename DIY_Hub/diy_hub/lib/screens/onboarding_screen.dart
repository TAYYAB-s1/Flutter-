// lib/screens/onboarding_screen.dart
// "CHOOSE YOUR HERO TIER": shown once on first launch. The user picks one of
// three age tiers; the choice is saved with ProgressService.completeOnboarding
// and the app continues to Home. Logic is unchanged from the old version,
// only the look is new.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/app_header.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/halftone_background.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/mission_cover.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _progressService = ProgressService();
  HeroTier? _selectedTier;
  bool _submitting = false;

  Future<void> _confirmSelection() async {
    final tier = _selectedTier;
    if (tier == null) return;
    setState(() => _submitting = true);
    await _progressService.completeOnboarding(tier);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Color _tierColor(HeroTier tier) {
    switch (tier) {
      case HeroTier.kids:
        return AppColors.tierKids;
      case HeroTier.teens:
        return AppColors.tierTeens;
      case HeroTier.adult:
        return AppColors.tierAdult;
    }
  }

  IconData _tierIcon(HeroTier tier) {
    switch (tier) {
      case HeroTier.kids:
        return Icons.rocket_launch;
      case HeroTier.teens:
        return Icons.build_circle;
      case HeroTier.adult:
        return Icons.architecture;
    }
  }

  String _tierBlurb(HeroTier tier) {
    switch (tier) {
      case HeroTier.kids:
        return 'Snap, build, launch. Epic first discoveries.';
      case HeroTier.teens:
        return 'Hands-on grit! Prototype circuitry, code gizmos, hot-rod gear.';
      case HeroTier.adult:
        return 'Pro-grade fabrication, precision mechanics, heavy power.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const HazardStrip(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: [
                Text('CHOOSE YOUR\nHERO TIER', style: AppText.display(size: 30)),
                const SizedBox(height: 8),
                Text(
                  'Pick your level to unlock missions made for you.',
                  style: AppText.bodyMuted(),
                ),
                const SizedBox(height: 24),
                for (final tier in HeroTier.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _TierCard(
                      title: tier.title,
                      ageRange: tier.ageRangeLabel,
                      blurb: _tierBlurb(tier),
                      color: _tierColor(tier),
                      icon: _tierIcon(tier),
                      selected: _selectedTier == tier,
                      onTap: () => setState(() => _selectedTier = tier),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.cream,
              border: Border(top: AppTheme.border),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrutalButton(
                    label: "Let's go",
                    icon: Icons.arrow_forward,
                    loading: _submitting,
                    onPressed: (_selectedTier != null && !_submitting) ? _confirmSelection : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'WORKS OFFLINE. NO ACCOUNT REQUIRED.',
                    style: AppText.tag(color: AppColors.muted, weight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String ageRange;
  final String blurb;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({
    required this.title,
    required this.ageRange,
    required this.blurb,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $ageRange',
      child: BrutalCard(
        onTap: onTap,
        color: color,
        // The selected card "pops" with a bigger shadow.
        shadowOffset: selected ? 8 : 4,
        clipBehavior: Clip.hardEdge,
        child: HalftoneBackground(
          dotColor: AppColors.halftoneDot,
          dotSpacing: 8,
          dotRadius: 1.2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CoverIconBox(icon: icon, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title.toUpperCase(), style: AppText.display(size: 20)),
                            const SizedBox(height: 4),
                            Text(ageRange.toUpperCase(), style: AppText.tag(size: 12)),
                            const SizedBox(height: 8),
                            Text(blurb, style: AppText.body(size: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ink : AppColors.white,
                      border: Border.fromBorderSide(AppTheme.tagBorder),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 20, color: AppColors.actionYellow)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
