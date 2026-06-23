import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 收集统计卡片组件
///
/// 展示首页的核心统计数据，包括：
/// - 猫咪总数：用户已记录的所有猫咪数量
/// - 今日日志数：当天创建的日志记录数
/// - 连续记录天数：用户连续打卡的天数
///
/// 采用三列并排的布局，每个统计项包含图标、数值和标签。
/// 支持自定义数值颜色和点击回调。
class CollectionStats extends StatelessWidget {
  /// 猫咪总数
  final int totalCats;

  /// 今日日志数
  final int todayLogs;

  /// 连续记录天数
  final int streakDays;

  /// 是否处于加载状态
  /// 为 true 时显示骨架屏效果
  final bool isLoading;

  /// 卡片点击回调（可选）
  final VoidCallback? onTap;

  /// 自定义数值文本颜色
  final Color? valueColor;

  const CollectionStats({
    super.key,
    required this.totalCats,
    required this.todayLogs,
    required this.streakDays,
    this.isLoading = false,
    this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValueColor = valueColor ?? AppColors.primary;

    final cardContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 猫咪总数
          _StatItem(
            icon: Icons.pets_rounded,
            value: isLoading ? '--' : '$totalCats',
            label: '只猫咪',
            color: effectiveValueColor,
            iconBackground: AppColors.primaryLight.withOpacity(0.2),
          ),

          // 分隔线
          Container(
            height: 40,
            width: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),

          // 今日日志数
          _StatItem(
            icon: Icons.edit_note_rounded,
            value: isLoading ? '--' : '$todayLogs',
            label: '今日记录',
            color: AppColors.secondary,
            iconBackground: AppColors.secondaryLight.withOpacity(0.2),
          ),

          // 分隔线
          Container(
            height: 40,
            width: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),

          // 连续记录天数
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            value: isLoading ? '--' : '$streakDays',
            label: '连续天数',
            color: AppColors.warning,
            iconBackground: AppColors.warning.withOpacity(0.15),
          ),
        ],
      ),
    );

    // 如果有点击回调，包裹 InkWell
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// 单个统计项子组件
///
/// 包含图标、数值和标签三部分的垂直布局。
class _StatItem extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 显示的数值（字符串形式，支持 '--' 等占位符）
  final String value;

  /// 标签文本
  final String label;

  /// 图标和数值的颜色
  final Color color;

  /// 图标背景色
  final Color iconBackground;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标容器
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),

        // 数值
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),

        // 标签
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
