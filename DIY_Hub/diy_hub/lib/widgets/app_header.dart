// lib/widgets/app_header.dart
// The black top bar used on every main screen: yellow bolt logo, the
// DIYHUB wordmark, and the white rank chip on the right. Use it as the
// Scaffold's appBar. Black here is a fixed design accent, not a dark theme.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/user_stats_model.dart';
import 'rank_chip.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Pass null while stats are still loading (the chip is simply hidden).
  final UserStatsModel? stats;

  const AppHeader({super.key, this.stats});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Container(
        color: AppColors.ink,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.actionYellow,
                      border: Border.fromBorderSide(AppTheme.tagBorder),
                    ),
                    child:
                        const Icon(Icons.bolt, size: 24, color: AppColors.ink),
                  ),
                  const SizedBox(width: 10),
                  Text('DIYHUB',
                      style: AppText.display(size: 20, color: AppColors.white)),
                  const Spacer(),
                  if (stats != null) RankChip.fromStats(stats!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
