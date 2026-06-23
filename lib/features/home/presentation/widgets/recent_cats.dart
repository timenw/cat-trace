import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../cat/domain/entities/cat_entity.dart';

/// 最近查看猫咪列表组件
///
/// 展示用户最近查看或添加的猫咪列表，最多显示 5 只。
/// 每个猫咪项显示头像（首字母或 emoji）、昵称、品种和最近观察时间。
/// 点击可跳转到猫咪详情页。
///
/// 当列表为空时，显示引导用户添加猫咪的提示。
class RecentCats extends StatelessWidget {
  /// 最近查看的猫咪列表
  final List<CatEntity> cats;

  /// 是否处于加载状态
  final bool isLoading;

  /// 查看全部点击回调（可选，默认跳转到猫咪列表页）
  final VoidCallback? onViewAll;

  const RecentCats({
    super.key,
    required this.cats,
    this.isLoading = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近查看',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (cats.isNotEmpty)
              TextButton(
                onPressed: onViewAll ?? () => context.push(RoutePaths.catList),
                child: const Text('查看全部'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 内容区域
        if (isLoading)
          _buildLoadingState()
        else if (cats.isEmpty)
          _buildEmptyState(context)
        else
          _buildCatList(context),
      ],
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                // 头像占位
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                // 名称占位
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text('🐱', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '还没有记录的猫咪',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '点击右下角 + 开始记录',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  /// 构建猫咪列表（水平滚动）
  Widget _buildCatList(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = cats[index];
          return _CatAvatar(
            cat: cat,
            onTap: () => context.push('${RoutePaths.catDetail.replaceAll(':catId', '${cat.id}')}'),
          );
        },
      ),
    );
  }
}

/// 单个猫咪头像组件
///
/// 显示猫咪的头像（使用 emoji 或首字母）、昵称和品种。
class _CatAvatar extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onTap;

  const _CatAvatar({
    required this.cat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = cat.displayName;
    final initial = displayName.isNotEmpty ? displayName[0] : '?';

    // 根据稀有度获取头像背景色
    final avatarColor = _getAvatarColor(cat.rarity);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            // 头像
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatarColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // 昵称
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),

            // 品种
            Text(
              cat.breed.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据稀有度获取头像颜色
  Color _getAvatarColor(dynamic rarity) {
    final rarityName = rarity.toString().split('.').last;
    switch (rarityName) {
      case 'legendary':
        return AppColors.rarityLegendary;
      case 'epic':
        return AppColors.rarityEpic;
      case 'rare':
        return AppColors.rarityRare;
      case 'uncommon':
        return AppColors.rarityUncommon;
      default:
        return AppColors.rarityCommon;
    }
  }
}
