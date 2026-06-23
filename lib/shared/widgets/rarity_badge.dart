import 'package:flutter/material.dart';

/// 猫咪稀有度枚举
enum CatRarity {
  /// 常见
  common('常见', 1),

  /// 稀有
  rare('稀有', 2),

  /// 史诗
  epic('史诗', 3),

  /// 传说
  legendary('传说', 4),

  /// 神话
  mythic('神话', 5);

  final String label;
  final int level;

  const CatRarity(this.label, this.level);
}

/// 稀有度徽章组件
/// 展示猫咪的稀有度等级，支持多种样式
class RarityBadge extends StatelessWidget {
  /// 稀有度
  final CatRarity rarity;

  /// 徽章大小
  final double size;

  /// 是否显示文字标签
  final bool showLabel;

  /// 是否显示星星
  final bool showStars;

  /// 自定义样式
  final RarityBadgeStyle style;

  /// 是否启用动画
  final bool animated;

  const RarityBadge({
    super.key,
    required this.rarity,
    this.size = 24,
    this.showLabel = true,
    this.showStars = false,
    this.style = RarityBadgeStyle.filled,
    this.animated = false,
  });

  /// 小型纯图标徽章
  const RarityBadge.dot({
    super.key,
    required this.rarity,
    this.size = 12,
    this.showLabel = false,
    this.showStars = false,
    this.style = RarityBadgeStyle.filled,
    this.animated = false,
  });

  /// 带星星的徽章
  const RarityBadge.withStars({
    super.key,
    required this.rarity,
    this.size = 20,
    this.showLabel = true,
    this.showStars = true,
    this.style = RarityBadgeStyle.filled,
    this.animated = true,
  });

  /// 获取稀有度对应的颜色
  static Color getRarityColor(CatRarity rarity) {
    switch (rarity) {
      case CatRarity.common:
        return const Color(0xFF9E9E9E); // 灰色
      case CatRarity.rare:
        return const Color(0xFF42A5F5); // 蓝色
      case CatRarity.epic:
        return const Color(0xFFAB47BC); // 紫色
      case CatRarity.legendary:
        return const Color(0xFFFFA726); // 橙色
      case CatRarity.mythic:
        return const Color(0xFFEF5350); // 红色
    }
  }

  /// 获取稀有度对应的渐变色
  static LinearGradient getRarityGradient(CatRarity rarity) {
    final color = getRarityColor(rarity);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getRarityColor(rarity);

    Widget badge = _buildBadge(color);

    if (animated) {
      badge = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildBadge(Color color) {
    switch (style) {
      case RarityBadgeStyle.filled:
        return _buildFilledBadge(color);
      case RarityBadgeStyle.outlined:
        return _buildOutlinedBadge(color);
      case RarityBadgeStyle.soft:
        return _buildSoftBadge(color);
    }
  }

  Widget _buildFilledBadge(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        gradient: getRarityGradient(rarity),
        borderRadius: BorderRadius.circular(size * 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStars) ...[
            ...List.generate(
              rarity.level,
              (index) => Icon(
                Icons.star_rounded,
                size: size * 0.7,
                color: Colors.white,
              ),
            ),
            if (showLabel) const SizedBox(width: 2),
          ],
          if (showLabel)
            Text(
              rarity.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutlinedBadge(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStars) ...[
            ...List.generate(
              rarity.level,
              (index) => Icon(
                Icons.star_rounded,
                size: size * 0.65,
                color: color,
              ),
            ),
            if (showLabel) const SizedBox(width: 2),
          ],
          if (showLabel)
            Text(
              rarity.label,
              style: TextStyle(
                color: color,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSoftBadge(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStars) ...[
            ...List.generate(
              rarity.level,
              (index) => Icon(
                Icons.star_rounded,
                size: size * 0.65,
                color: color,
              ),
            ),
            if (showLabel) const SizedBox(width: 2),
          ],
          if (showLabel)
            Text(
              rarity.label,
              style: TextStyle(
                color: color,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// 稀有度徽章样式
enum RarityBadgeStyle {
  /// 填充样式
  filled,

  /// 描边样式
  outlined,

  /// 柔和样式
  soft,
}

/// 稀有度进度条
/// 展示当前稀有度等级和进度
class RarityProgressBar extends StatelessWidget {
  /// 当前稀有度
  final CatRarity currentRarity;

  /// 当前经验值
  final int currentExp;

  /// 升级所需经验值
  final int maxExp;

  /// 高度
  final double height;

  /// 是否显示文字
  final bool showText;

  const RarityProgressBar({
    super.key,
    required this.currentRarity,
    required this.currentExp,
    required this.maxExp,
    this.height = 8,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = RarityBadge.getRarityColor(currentRarity);
    final progress = maxExp > 0 ? currentExp / maxExp : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showText)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RarityBadge.dot(rarity: currentRarity, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    currentRarity.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentExp / $maxExp',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        if (showText) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
