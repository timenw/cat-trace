import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 空状态组件
/// 
/// 用于展示列表为空时的提示
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  const EmptyState.noCats({super.key, this.onAction})
      : icon = Icons.pets,
        title = '还没有记录的猫咪',
        subtitle = '点击右下角添加第一只猫吧',
        actionLabel = '添加猫咪';

  const EmptyState.noLogs({super.key, this.onAction})
      : icon = Icons.note_alt,
        title = '还没有观察记录',
        subtitle = '记录猫咪的可爱瞬间吧',
        actionLabel = '添加记录';

  const EmptyState.noAchievements({super.key})
      : icon = Icons.emoji_events_outlined,
        title = '还没有解锁成就',
        subtitle = '继续收集和记录来解锁成就吧',
        actionLabel = null,
        onAction = null;

  const EmptyState.noSearchResults({super.key})
      : icon = Icons.search_off,
        title = '没有找到匹配的猫咪',
        subtitle = '换个关键词试试吧',
        actionLabel = null,
        onAction = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.lightTextHint.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: AppColors.lightTextHint),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}