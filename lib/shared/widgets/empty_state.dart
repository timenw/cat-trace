import 'package:flutter/material.dart';

/// 空状态组件
/// 当列表或页面没有数据时展示，支持自定义图标、标题、副标题和操作按钮
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题文本
  final String title;

  /// 副标题/描述文本
  final String? subtitle;

  /// 操作按钮文本
  final String? actionText;

  /// 操作按钮点击回调
  final VoidCallback? onAction;

  /// 自定义图标组件（优先级高于 icon）
  final Widget? iconWidget;

  /// 自定义内容组件（显示在标题下方）
  final Widget? content;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 整体内边距
  final EdgeInsetsGeometry padding;

  /// 图标与标题之间的间距
  final double spacing;

  const EmptyState({
    super.key,
    this.icon = Icons.pets_rounded,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconWidget,
    this.content,
    this.iconSize = 80,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
  });

  /// 预设：暂无猫咪
  const EmptyState.noCats({
    super.key,
    this.subtitle = '快去探索发现你的第一只猫吧！',
    this.actionText = '去探索',
    this.onAction,
    this.content,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
  })  : icon = Icons.pets_rounded,
        iconSize = 80,
        iconColor = null,
        title = '还没有猫咪',
        titleStyle = null,
        subtitleStyle = null,
        iconWidget = null;

  /// 预设：暂无收藏
  const EmptyState.noFavorites({
    super.key,
    this.subtitle = '收藏喜欢的猫咪，方便随时查看',
    this.actionText = '去浏览',
    this.onAction,
    this.content,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
  })  : icon = Icons.favorite_border_rounded,
        iconSize = 80,
        iconColor = null,
        title = '暂无收藏',
        titleStyle = null,
        subtitleStyle = null,
        iconWidget = null;

  /// 预设：暂无搜索结果
  const EmptyState.noResults({
    super.key,
    this.subtitle = '换个关键词试试吧',
    this.onAction,
    this.content,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
  })  : icon = Icons.search_off_rounded,
        iconSize = 80,
        iconColor = null,
        title = '没有找到结果',
        actionText = null,
        titleStyle = null,
        subtitleStyle = null,
        iconWidget = null;

  /// 预设：暂无成就
  const EmptyState.noAchievements({
    super.key,
    this.subtitle = '收集更多猫咪来解锁成就吧！',
    this.onAction,
    this.content,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
  })  : icon = Icons.emoji_events_outlined,
        iconSize = 80,
        iconColor = null,
        title = '暂无成就',
        actionText = null,
        titleStyle = null,
        subtitleStyle = null,
        iconWidget = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标区域
            iconWidget ??
                Container(
                  width: iconSize * 1.5,
                  height: iconSize * 1.5,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: effectiveIconColor,
                  ),
                ),

            SizedBox(height: spacing),

            // 标题
            Text(
              title,
              style: titleStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            // 副标题
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: subtitleStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // 自定义内容
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            // 操作按钮
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
