import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../presentation/providers/achievement_providers.dart';
import '../../presentation/widgets/achievement_card.dart';
import 'achievement_grid.dart' as grid_widget;

/// 成就页面
///
/// 展示用户的成就列表，支持按分类筛选和点击查看详情。
class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ====== 顶部栏 ======
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '成就',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
          ),

          // ====== 成就统计 ======
          achievements.when(
            data: (list) {
              final total = list.length;
              final unlocked = list.where((a) => a.isUnlocked).length;
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem('总成就', '$total'),
                        _StatItem('已解锁', '$unlocked'),
                        _StatItem('完成率', '${total > 0 ? ((unlocked / total) * 100).toInt() : 0}%'),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // ====== 成就列表 ======
          achievements.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState.noAchievements(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                sliver: grid_widget.AchievementGrid(
                  achievements: list,
                  onAchievementTap: (achievement) {
                    _showAchievementDetail(context, achievement);
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text('加载失败: $error')),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示成就详情
  void _showAchievementDetail(BuildContext context, dynamic achievement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(achievement.name),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('进度: ${achievement.progress}/${achievement.target}'),
                const Spacer(),
                Text(achievement.rarityDisplayName),
              ],
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text('解锁时间: ${DateFormat('yyyy-MM-dd HH:mm').format(achievement.unlockedAt!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 统计项组件
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextHint,
          ),
        ),
      ],
    );
  }
}
