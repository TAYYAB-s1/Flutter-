// lib/screens/onboarding_screen.dart
// "Choose Your Hero Tier" — shown once on first launch.
// NOTE: This is a functional Phase 1 version. Full comic-panel styling,
// halftone backgrounds, and burst badges are added in the Screens phase.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
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
    if (_selectedTier == null) return;
    setState(() => _submitting = true);
    await _progressService.completeOnboarding(_selectedTier!);
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
        return 'Epic first steps! Build, snap, launch, and discover everyday magic.';
      case HeroTier.teens:
        return 'Hands-on grit! Prototype circuitry, code gizmos, and hot-rod your gear.';
      case HeroTier.adult:
        return 'Pro-grade fabrication, precision mechanics, restoration, and heavy power.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'CHOOSE YOUR\nHERO TIER!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your level to unlock tailored DIY missions & gear!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: HeroTier.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final tier = HeroTier.values[index];
                    final isSelected = _selectedTier == tier;
                    return _HeroTierCard(
                      title: tier.title,
                      ageRange: tier.ageRangeLabel,
                      blurb: _tierBlurb(tier),
                      color: _tierColor(tier),
                      icon: _tierIcon(tier),
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedTier = tier),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_selectedTier != null && !_submitting) ? _confirmSelection : null,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("LET'S GO! 🚀"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTierCard extends StatelessWidget {
  final String title;
  final String ageRange;
  final String blurb;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeroTierCard({
    required this.title,
    required this.ageRange,
    required this.blurb,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$title  •  $ageRange', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(blurb, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}