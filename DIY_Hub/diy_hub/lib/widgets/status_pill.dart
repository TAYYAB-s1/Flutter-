// lib/widgets/status_pill.dart
// Square status pill for a mission: NOT STARTED, IN PROGRESS 2/4, COMPLETED.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

enum MissionStatus { notStarted, inProgress, completed }

/// Works out the status from how many episodes are done.
MissionStatus missionStatusFor({
  required int completedEpisodes,
  required int totalEpisodes,
}) {
  if (totalEpisodes > 0 && completedEpisodes >= totalEpisodes) {
    return MissionStatus.completed;
  }
  if (completedEpisodes > 0) return MissionStatus.inProgress;
  return MissionStatus.notStarted;
}

class StatusPill extends StatelessWidget {
  final MissionStatus status;
  final int completedEpisodes;
  final int totalEpisodes;

  const StatusPill({
    super.key,
    required this.status,
    this.completedEpisodes = 0,
    this.totalEpisodes = 0,
  });

  /// Convenience: derive the status from the episode counts.
  factory StatusPill.fromProgress({
    Key? key,
    required int completedEpisodes,
    required int totalEpisodes,
  }) {
    return StatusPill(
      key: key,
      status: missionStatusFor(
        completedEpisodes: completedEpisodes,
        totalEpisodes: totalEpisodes,
      ),
      completedEpisodes: completedEpisodes,
      totalEpisodes: totalEpisodes,
    );
  }

  Color get _color {
    switch (status) {
      case MissionStatus.notStarted:
        return AppColors.locked;
      case MissionStatus.inProgress:
        return AppColors.inProgress;
      case MissionStatus.completed:
        return AppColors.success;
    }
  }

  String get _text {
    switch (status) {
      case MissionStatus.notStarted:
        return 'NOT STARTED';
      case MissionStatus.inProgress:
        return 'IN PROGRESS $completedEpisodes/$totalEpisodes';
      case MissionStatus.completed:
        return 'COMPLETED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == MissionStatus.completed) ...[
            const Icon(Icons.check, size: 13, color: AppColors.ink),
            const SizedBox(width: 4),
          ],
          Text(_text, style: AppText.tag()),
        ],
      ),
    );
  }
}
