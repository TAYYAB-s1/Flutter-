// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/tools_data.dart';
import '../models/conversion_model.dart';
import '../widgets/tool_card.dart';
import '../screens/all_tools_screen.dart';
import 'tool_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  final bool         isDark;
  final VoidCallback onThemeToggle;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ConversionModel> _recentConversions = [];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned         : true,
            expandedHeight : 0,
            title: Row(
              children: [
                Container(
                  width      : 32,
                  height     : 32,
                  decoration : BoxDecoration(
                    gradient     : const LinearGradient(
                        colors: AppColors.bannerGradient),
                    borderRadius : BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('ConvertIt',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 20)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(widget.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded),
                onPressed: widget.onThemeToggle,
                tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ───────────────────────────────────────────
                _HeroBanner(greeting: _greeting()),
                const SizedBox(height: 28),

                // ── Popular Tools ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Popular Tools',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AllToolsScreen()),
                        ),
                        child: const Text('View All →'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics    : const NeverScrollableScrollPhysics(),
                    shrinkWrap : true,
                    itemCount  : 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount   : 2,
                      crossAxisSpacing : 12,
                      mainAxisSpacing  : 12,
                      childAspectRatio : 0.88,
                    ),
                    itemBuilder: (_, i) => ToolCard(
                      tool  : kAllTools[i],
                      onTap : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ToolDetailScreen(tool: kAllTools[i]),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Recently Converted ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Recently Converted',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                _recentConversions.isEmpty
                    ? _EmptyRecent(isDark: isDark)
                    : _RecentList(
                        conversions : _recentConversions.take(3).toList(),
                        isDark      : isDark,
                      ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width  : double.infinity,
      margin : const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.bannerGradient,
          begin : Alignment.topLeft,
          end   : Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Convert any file,\ninstantly.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 8),
          const Text('PDF, Word, Images and more —\npowered by CloudConvert.',
              style: TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(icon: Icons.swap_horiz_rounded, label: '12 Tools'),
              const SizedBox(width: 10),
              _StatChip(icon: Icons.bolt_rounded,       label: 'Fast & Free'),
              const SizedBox(width: 10),
              _StatChip(icon: Icons.lock_rounded,       label: 'Secure'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color        : Colors.white.withOpacity(0.18),
        borderRadius : BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Empty Recent ─────────────────────────────────────────────────────────────

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin : const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius : BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8)
              ],
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded,
              size: 52,
              color: isDark
                  ? const Color(0xFF444444)
                  : const Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          Text('No recent files yet',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF888888)
                      : const Color(0xFFAAAAAA))),
          const SizedBox(height: 4),
          Text('Your converted files will appear here',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF666666)
                      : const Color(0xFFBBBBBB))),
        ],
      ),
    );
  }
}

// ── Recent List ──────────────────────────────────────────────────────────────

class _RecentList extends StatelessWidget {
  const _RecentList({required this.conversions, required this.isDark});
  final List<ConversionModel> conversions;
  final bool                  isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: conversions
            .map((c) => _RecentItem(conversion: c, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({required this.conversion, required this.isDark});
  final ConversionModel conversion;
  final bool            isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius : BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width      : 40,
            height     : 40,
            decoration : BoxDecoration(
              color        : conversion.toolColor.withOpacity(0.15),
              borderRadius : BorderRadius.circular(10),
            ),
            child: Icon(Icons.insert_drive_file_rounded,
                color: conversion.toolColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversion.outputFileName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    '${conversion.toolName} • ${conversion.formattedSize}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF888888))),
              ],
            ),
          ),
          Icon(Icons.download_rounded,
              size: 20,
              color: isDark
                  ? const Color(0xFF666666)
                  : const Color(0xFFBBBBBB)),
        ],
      ),
    );
  }
}