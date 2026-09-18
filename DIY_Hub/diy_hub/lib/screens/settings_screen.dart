// lib/screens/settings_screen.dart
// "Settings" tab — theme mode, Hero Tier change, about/help/privacy links,
// and a data reset option. Rendered as a tab body inside HomeScreen's
// shared Scaffold (no own AppBar).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../main.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _progressService = ProgressService();
  UserStatsModel? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _progressService.getUserStats();
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _pickThemeMode() async {
    final controller = ThemeController.of(context);
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('CHOOSE THEME', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 4),
              ...ThemeMode.values.map(
                (mode) => RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: controller.themeMode,
                  title: Text(_themeLabel(mode)),
                  onChanged: (value) => Navigator.of(sheetContext).pop(value),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      controller.setThemeMode(selected);
    }
  }

  Future<void> _pickHeroTier() async {
    if (_stats == null) return;
    final currentTier = _stats!.heroTier;

    final selected = await showModalBottomSheet<HeroTier>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('CHANGE HERO TIER', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 4),
              ...HeroTier.values.map(
                (tier) => RadioListTile<HeroTier>(
                  value: tier,
                  groupValue: currentTier,
                  title: Text(tier.title),
                  subtitle: Text(tier.ageRangeLabel),
                  onChanged: (value) => Navigator.of(sheetContext).pop(value),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await _progressService.setHeroTier(selected);
      _load();
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will erase your XP, rank, completed missions, favorites, and '
          'Hero Tier selection. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _progressService.resetAll();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ThemeController.of(context).themeMode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(title: 'Appearance'),
        _SettingsTile(
          icon: Icons.brightness_6,
          title: 'Theme',
          value: _themeLabel(themeMode),
          onTap: _pickThemeMode,
        ),
        _SettingsTile(
          icon: Icons.group,
          title: 'Hero Tier',
          value: _stats?.heroTier.title ?? '—',
          onTap: _pickHeroTier,
        ),
        const SizedBox(height: 20),
        const _SectionHeader(title: 'About'),
        const _SettingsTile(
          icon: Icons.info_outline,
          title: 'App Version',
          value: 'v1.0.0',
        ),
        _SettingsTile(icon: Icons.star_border, title: 'Rate the App', onTap: _showComingSoon),
        _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: _showComingSoon),
        _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: _showComingSoon),
        const SizedBox(height: 20),
        const _SectionHeader(title: 'Data'),
        _SettingsTile(
          icon: Icons.delete_outline,
          title: 'Reset All Data',
          titleColor: AppColors.error,
          onTap: _confirmResetProgress,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outline, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: titleColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(value!, style: Theme.of(context).textTheme.bodySmall),
                ),
              if (onTap != null)
                Icon(Icons.chevron_right, size: 20, color: outline.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}