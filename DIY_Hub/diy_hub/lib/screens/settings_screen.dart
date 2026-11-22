// lib/screens/settings_screen.dart
// The CONFIG tab: Profile (change Hero Tier, see your rank), About (version
// and links) and Data (reset everything). The app is light-only, so there is
// no theme toggle any more.
// Rendered as a tab body inside HomeScreen's shared Scaffold.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/sticker_label.dart';
import '../widgets/tech_tag.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  /// Called after data changes (e.g. a new Hero Tier) so Home can refresh.
  final VoidCallback? onDataChanged;

  const SettingsScreen({super.key, this.onDataChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _appVersion = 'v1.0.0';

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

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Coming soon!')));
  }

  Future<void> _pickHeroTier() async {
    final stats = _stats;
    if (stats == null) return;

    final selected = await showModalBottomSheet<HeroTier>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(side: AppTheme.border),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CHANGE HERO TIER', style: AppText.display(size: 22)),
              const SizedBox(height: 6),
              Text('You can change this any time.', style: AppText.bodyMuted()),
              const SizedBox(height: 18),
              for (final tier in HeroTier.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14, right: 4),
                  child: _TierOption(
                    tier: tier,
                    selected: tier == stats.heroTier,
                    onTap: () => Navigator.of(sheetContext).pop(tier),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && selected != stats.heroTier) {
      await _progressService.setHeroTier(selected);
      await _load();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => const _ResetDialog(),
    );
    if (confirmed != true) return;

    await _progressService.resetAll();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text('SETTINGS', style: AppText.display(size: 30)),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: StickerLabel(text: 'Profile')),
        const SizedBox(height: 14),
        _SettingsRow(
          icon: Icons.groups,
          title: 'Hero tier',
          subtitle: stats == null ? '...' : '${stats.heroTier.title} (${stats.heroTier.ageRangeLabel})',
          onTap: _pickHeroTier,
          trailing: BrutalButton(
            label: 'Change',
            expand: false,
            height: 44,
            fontSize: 13,
            style: BrutalButtonStyle.secondary,
            onPressed: _pickHeroTier,
          ),
        ),
        _SettingsRow(
          icon: Icons.emoji_events,
          title: 'Rank',
          subtitle: stats == null
              ? '...'
              : '${stats.currentRank.label} · ${stats.totalXp} XP',
        ),
        const SizedBox(height: 14),
        const Align(alignment: Alignment.centerLeft, child: StickerLabel(text: 'About')),
        const SizedBox(height: 14),
        _SettingsRow(
          icon: Icons.info_outline,
          title: 'App version',
          trailing: Text(_appVersion.toUpperCase(), style: AppText.tag(size: 12)),
        ),
        _SettingsRow(
          icon: Icons.star_border,
          title: 'Rate the app',
          onTap: _comingSoon,
          trailing: const _Chevron(),
        ),
        _SettingsRow(
          icon: Icons.help_outline,
          title: 'Help & support',
          onTap: _comingSoon,
          trailing: const _Chevron(),
        ),
        _SettingsRow(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy policy',
          onTap: _comingSoon,
          trailing: const _Chevron(),
        ),
        const SizedBox(height: 14),
        const Align(alignment: Alignment.centerLeft, child: StickerLabel(text: 'Data')),
        const SizedBox(height: 14),
        _SettingsRow(
          icon: Icons.warning_amber_rounded,
          title: 'Reset all data',
          subtitle: 'Erase XP, rank, progress and favorites',
          color: AppColors.danger,
          onTap: _confirmReset,
          trailing: const _Chevron(),
        ),
        const SizedBox(height: 20),
        const HazardStrip(),
      ],
    );
  }
}

/// One settings row: icon box, title, optional subtitle and a trailing widget.
/// Rows without [onTap] are read-only and drawn flat (no shadow).
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color color;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 4),
      child: BrutalCard(
        onTap: onTap,
        color: color,
        shadowOffset: onTap == null ? 0 : 4,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border.fromBorderSide(AppTheme.tagBorder),
              ),
              child: Icon(icon, size: 22, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppText.display(size: 14, height: 1.15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: AppText.caption(color: onTap != null && color != AppColors.white
                          ? AppColors.ink
                          : AppColors.muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chevron_right, size: 26, color: AppColors.ink);
  }
}

/// One choice in the Hero Tier bottom sheet (square check box, no Material
/// radio, so it matches the rest of the app).
class _TierOption extends StatelessWidget {
  final HeroTier tier;
  final bool selected;
  final VoidCallback onTap;

  const _TierOption({required this.tier, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = tierColor(tier);

    return Semantics(
      button: true,
      selected: selected,
      label: '${tier.title}, ${tier.ageRangeLabel}',
      child: BrutalCard(
        onTap: onTap,
        color: selected ? Color.alphaBlend(accent.withValues(alpha: 0.35), AppColors.white) : AppColors.white,
        shadowOffset: selected ? 6 : 4,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : AppColors.white,
                border: const Border.fromBorderSide(AppTheme.tagBorder),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 20, color: AppColors.actionYellow)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier.title.toUpperCase(), style: AppText.display(size: 15, height: 1.15)),
                  const SizedBox(height: 2),
                  Text(tier.ageRangeLabel, style: AppText.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "RESET ALL DATA?" confirmation. Pops true when the user confirms.
class _ResetDialog extends StatelessWidget {
  const _ResetDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: BrutalCard(
        shadowOffset: 8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('RESET ALL DATA?', style: AppText.display(size: 22)),
            const SizedBox(height: 10),
            Text(
              'This erases your XP, rank, progress and favorites. This cannot be undone.',
              style: AppText.body(size: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BrutalButton(
                    label: 'Cancel',
                    style: BrutalButtonStyle.secondary,
                    fontSize: 14,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrutalButton(
                    label: 'Reset',
                    style: BrutalButtonStyle.danger,
                    fontSize: 14,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
