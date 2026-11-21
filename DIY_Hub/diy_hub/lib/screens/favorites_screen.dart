
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.ink));
    }

    final favorites = SkillsData.all
        .where((skill) => _allProgress[skill.id]?.isFavorite ?? false)
        .toList();

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text('FAVORITES', style: AppText.display(size: 30)),
          const SizedBox(height: 8),
          Text(
            '${favorites.length} SAVED',
            style: AppText.tag(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          if (favorites.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.bookmark_border,
                title: 'No favorites yet',
                message: 'Tap the bookmark on any mission to save it here.',
                actionLabel: 'Browse missions',
                onAction: () => TabRequest.go(1),
              ),
            )
          else
            MissionGrid(
              skills: favorites,
              progress: _allProgress,
              onOpen: _open,
              onToggleFavorite: _toggleFavorite,
            ),
          const SizedBox(height: 28),
          const HazardStrip(),
        ],
      ),
    );
  }
}
