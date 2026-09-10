// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool   _autoDelete   = true;
  String _cacheSize    = '...';
  int    _historyCount = 0;
  bool   _isClearing   = false;

  static const List<_ColorOption> _colorOptions = [
    _ColorOption(color: AppColors.primary,      label: 'Red'),
    _ColorOption(color: Color(0xFF1E88E5),       label: 'Blue'),
    _ColorOption(color: Color(0xFF43A047),       label: 'Green'),
    _ColorOption(color: Color(0xFF8E24AA),       label: 'Purple'),
    _ColorOption(color: Color(0xFFF9A825),       label: 'Yellow'),
    _ColorOption(color: Color(0xFF00897B),       label: 'Teal'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final autoDelete   = await StorageService.instance.loadAutoDelete();
    final cacheSize    = await StorageService.instance.formattedCacheSize();
    final historyCount = await StorageService.instance.historyCount();
    if (!mounted) return;
    setState(() {
      _autoDelete   = autoDelete;
      _cacheSize    = cacheSize;
      _historyCount = historyCount;
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(
          'This will delete all $_historyCount saved conversions ($_cacheSize). '
          'Downloaded files on your device will not be affected.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isClearing = true);
      await StorageService.instance.clearHistory();
      await _loadSettings();
      setState(() => _isClearing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cache cleared successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF43A047),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── APPEARANCE ──────────────────────────────────────────────
          _SectionHeader(label: 'Appearance', isDark: isDark),
          const SizedBox(height: 10),

          _SettingsCard(
            isDark: isDark,
            children: [

              // Dark mode toggle
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.fromLTRB(16, 6, 12, 6),
                secondary: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E24AA).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: const Color(0xFF8E24AA), size: 20,
                  ),
                ),
                title: const Text('Dark Mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  widget.isDark ? 'Currently dark' : 'Currently light',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                value      : widget.isDark,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged  : (_) => widget.onThemeToggle(),
              ),

              _Divider(isDark: isDark),

              // Color theme picker
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: widget.seedColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.palette_rounded,
                              color: widget.seedColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('App Color Theme',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Text('Choose your accent color',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: _colorOptions.map((opt) {
                        final selected =
                            widget.seedColor.value == opt.color.value;
                        return GestureDetector(
                          onTap: () {
                            widget.onSeedColorChange(opt.color);
                            StorageService.instance
                                .saveSeedColor(opt.color.value);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: opt.color,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      width: 3)
                                  : null,
                              boxShadow: selected
                                  ? [BoxShadow(
                                      color: opt.color.withValues(alpha: 0.5),
                                      blurRadius: 8)]
                                  : [],
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── STORAGE ─────────────────────────────────────────────────
          _SectionHeader(label: 'Storage', isDark: isDark),
          const SizedBox(height: 10),

          _SettingsCard(
            isDark: isDark,
            children: [

              SwitchListTile(
                contentPadding:
                    const EdgeInsets.fromLTRB(16, 6, 12, 6),
                secondary: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9A825).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_delete_rounded,
                      color: Color(0xFFF9A825), size: 20),
                ),
                title: const Text('Auto-delete Files',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Remove server files after 1 hour',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                value      : _autoDelete,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged  : (v) async {
                  setState(() => _autoDelete = v);
                  await StorageService.instance.saveAutoDelete(v);
                },
              ),

              _Divider(isDark: isDark),

              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storage_rounded,
                      color: Colors.red, size: 20),
                ),
                title: const Text('Conversion History',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '$_historyCount saved • $_cacheSize',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: _isClearing
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _historyCount > 0 ? _clearCache : null,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Clear',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── ABOUT ────────────────────────────────────────────────────
          _SectionHeader(label: 'About', isDark: isDark),
          const SizedBox(height: 10),

          _SettingsCard(
            isDark: isDark,
            children: [
              _InfoTile(icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  label: 'App Version', trailing: 'v1.0.0', isDark: isDark),
              _Divider(isDark: isDark),
              _InfoTile(icon: Icons.api_rounded,
                  iconColor: const Color(0xFF43A047),
                  label: 'Powered by', trailing: 'CloudConvert', isDark: isDark),
              _Divider(isDark: isDark),
              _InfoTile(icon: Icons.swap_horiz_rounded,
                  iconColor: AppColors.primary,
                  label: 'Total Tools', trailing: '12 Converters', isDark: isDark),
              _Divider(isDark: isDark),
              _InfoTile(icon: Icons.school_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  label: 'Project',
                  trailing: 'UMT — AI Spring 2026', isDark: isDark),
            ],
          ),

          const SizedBox(height: 24),

          // ── Brand footer ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.1),
                  const Color(0xFFFB8C00)
                      .withValues(alpha: isDark ? 0.3 : 0.1),
                ],
                begin: Alignment.topLeft,
                end  : Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.bannerGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                const Text('ConvertIt',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Convert any file, instantly.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF888888)
                          : const Color(0xFF757575),
                    )),
                const SizedBox(height: 4),
                Text('Made with ❤️ by Tayyab',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF666666)
                          : const Color(0xFFAAAAAA),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ColorOption {
  const _ColorOption({required this.color, required this.label});
  final Color  color;
  final String label;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize     : 11,
        fontWeight   : FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark
            ? const Color(0xFF888888)
            : const Color(0xFF999999),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool         isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
    required this.isDark,
  });
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   trailing;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Text(trailing,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? const Color(0xFF888888)
                : const Color(0xFF757575),
          )),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      color: isDark
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFEEEEEE),
    );
  }
}