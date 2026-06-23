import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cat_entity.dart';
import 'tnr_badge.dart';

/// 猫咪详情页头部组件
///
/// 展示猫咪的大头像、昵称、品种、性别、年龄和 TNR 状态。
class CatHeader extends StatelessWidget {
  /// 猫咪实体
  final CatEntity cat;

  const CatHeader({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 大头像
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _getCatColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: _getCatColor(),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '🐱',
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 昵称
          Text(
            cat.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // 品种 · 年龄
          Text(
            '${cat.breed.displayName} · ${cat.ageDisplayText}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // 标签行
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 性别标签
              _GenderBadge(gender: cat.gender),
              const SizedBox(width: 8),
              // TNR 状态徽章
              TnrBadge(status: cat.tnrStatus),
              const SizedBox(width: 8),
              // 稀有度标签
              _RarityBadge(rarity: cat.rarity),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCatColor() {
    switch (cat.color.name) {
      case 'orange':
        return const Color(0xFFFF8A65);
      case 'black':
        return const Color(0xFF424242);
      case 'white':
        return const Color(0xFFBDBDBD);
      case 'tabby':
        return const Color(0xFFBCAAA4);
      case 'calico':
        return const Color(0xFFFFAB91);
      case 'tuxedo':
        return const Color(0xFF546E7A);
      case 'gray':
        return const Color(0xFF90A4AE);
      case 'cream':
        return const Color(0xFFFFE082);
      case 'tortoiseshell':
        return const Color(0xFFA1887F);
      default:
        return AppColors.primary;
    }
  }
}

/// 性别标签
class _GenderBadge extends StatelessWidget {
  final dynamic gender; // CatGender

  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isMale = gender.toString() == 'CatGender.male';
    final isFemale = gender.toString() == 'CatGender.female';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMale
            ? AppColors.accent.withOpacity(0.1)
            : isFemale
                ? Colors.pink.withOpacity(0.1)
                : AppColors.lightTextHint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMale ? Icons.male : isFemale ? Icons.female : Icons.help_outline,
            size: 14,
            color: isMale
                ? AppColors.accent
                : isFemale
                    ? Colors.pink
                    : AppColors.lightTextHint,
          ),
          const SizedBox(width: 4),
          Text(
            isMale ? '公猫' : isFemale ? '母猫' : '未知',
            style: TextStyle(
              fontSize: 12,
              color: isMale
                  ? AppColors.accent
                  : isFemale
                      ? Colors.pink
                      : AppColors.lightTextHint,
            ),
          ),
        ],
      ),
    );
  }
}

/// 稀有度标签
class _RarityBadge extends StatelessWidget {
  final dynamic rarity; // Rarity

  const _RarityBadge({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = Color(rarity.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rarity.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
