import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// 快速操作区域组件
///
/// 提供首页的快捷操作入口，包括：
/// - 拍照记录：快速添加一只新猫咪
/// - 投喂记录：为已有猫咪添加投喂日志
/// - 健康观察：记录猫咪的健康状况
/// - 查看日历：跳转到日历页面
///
/// 采用 2x2 网格布局，每个操作卡片包含图标、标题和颜色主题。
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        icon: Icons.add_a_photo_rounded,
        title: '拍照记录',
        subtitle: '发现新猫咪',
        color: AppColors.primary,
        onTap: () => context.push(RoutePaths.addCat),
      ),
      _QuickActionData(
        icon: Icons.restaurant_rounded,
        title: '投喂记录',
        subtitle: '记录喂食',
        color: AppColors.secondary,
        onTap: () {
          // TODO: 选择猫咪后跳转到投喂记录页面
          // 当前先跳转到猫咪列表
          context.push(RoutePaths.catList);
        },
      ),
      _QuickActionData(
        icon: Icons.health_and_safety_rounded,
        title: '健康观察',
        subtitle: '记录健康状况',
        color: AppColors.accent,
        onTap: () {
          // TODO: 选择猫咪后跳转到健康观察页面
          context.push(RoutePaths.catList);
        },
      ),
      _QuickActionData(
        icon: Icons.calendar_month_rounded,
        title: '查看日历',
        subtitle: '时间线回顾',
        color: AppColors.warning,
        onTap: () => context.push(RoutePaths.calendar),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '快速操作',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // 2x2 网格布局
        Row(
          children: [
            // 左列
            Expanded(
              child: Column(
                children: [
                  _QuickActionCard(action: actions[0]),
                  const SizedBox(height: 12),
                  _QuickActionCard(action: actions[2]),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 右列
            Expanded(
              child: Column(
                children: [
                  _QuickActionCard(action: actions[1]),
                  const SizedBox(height: 12),
                  _QuickActionCard(action: actions[3]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 快速操作数据模型
///
/// 封装单个快速操作的所有配置信息。
class _QuickActionData {
  /// 操作图标
  final IconData icon;

  /// 操作标题
  final String title;

  /// 操作副标题（简短描述）
  final String subtitle;

  /// 主题颜色
  final Color color;

  /// 点击回调
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

/// 单个快速操作卡片
///
/// 包含图标、标题和副标题，点击后执行对应操作。
/// 使用 InkWell 提供水波纹反馈效果。
class _QuickActionCard extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = action.color.withOpacity(0.1);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: bgColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  action.icon,
                  size: 24,
                  color: action.color,
                ),
              ),
              const SizedBox(height: 12),

              // 标题
              Text(
                action.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),

              // 副标题
              Text(
                action.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
