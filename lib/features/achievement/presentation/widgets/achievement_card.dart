import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/achievement_entity.dart';

/// 成就卡片组件
class AchievementCard extends StatelessWidget {
  final AchievementEntity achievement;
  final bool compact;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercent;

    return Card(
      color: isUnlocked ? null : AppColors.lightCard.withAlpha(128),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getRarityColor().withAlpha(30)
                    : AppColors.lightDivider,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: isUnlocked ? null : AppColors.lightTextHint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        achievement.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? null : AppColors.lightTextHint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRarityColor().withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            achievement.rarityDisplayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getRarityColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnlocked ? null : AppColors.lightTextHint,
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.lightDivider,
                      valueColor: AlwaysStoppedAnimation(_getRarityColor()),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.progressText,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
            // 解锁状态
            if (isUnlocked)
              const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.rarityCommon;
      case AchievementRarity.uncommon:
        return AppColors.rarityUncommon;
      case AchievementRarity.rare:
        return AppColors.rarityRare;
      case AchievementRarity.epic:
        return AppColors.rarityEpic;
      case AchievementRarity.legendary:
        return AppColors.rarityLegendary;
    }
  }
}

/// 成就网格组件
class AchievementGrid extends StatelessWidget {
  final List<AchievementEntity> achievements;
  final Function(AchievementEntity)? onTap;

  const AchievementGrid({super.key, required this.achievements, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('暂无成就'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return InkWell(
          onTap: onTap != null ? () => onTap!(achievement) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? _getRarityColor(achievement.rarity).withAlpha(15)
                  : AppColors.lightCard.withAlpha(128),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: achievement.isUnlocked
                    ? _getRarityColor(achievement.rarity).withAlpha(50)
                    : AppColors.lightDivider,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: achievement.isUnlocked ? null : AppColors.lightTextHint,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? null : AppColors.lightTextHint,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 4),
                  Text(
                    achievement.progressPercentText,
                    style: const TextStyle(fontSize: 10, color: AppColors.lightTextHint),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return AppColors.rarityCommon;
      case AchievementRarity.uncommon:
        return AppColors.rarityUncommon;
      case AchievementRarity.rare:
        return AppColors.rarityRare;
      case AchievementRarity.epic:
        return AppColors.rarityEpic;
      case AchievementRarity.legendary:
        return AppColors.rarityLegendary;
    }
  }
}
