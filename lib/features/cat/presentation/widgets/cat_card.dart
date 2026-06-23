import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/cat_entity.dart';
import '../widgets/tnr_badge.dart';

/// 猫咪卡片组件
///
/// 在猫咪列表页中以卡片形式展示猫咪信息，包括头像、昵称、品种、TNR 状态等。
class CatCard extends StatelessWidget {
  /// 猫咪实体
  final CatEntity cat;

  /// 点击回调
  final VoidCallback? onTap;

  const CatCard({
    super.key,
    required this.cat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像区域
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: _getCatColor(),
                child: Center(
                  child: Text(
                    _getCatEmoji(),
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            // 信息区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称
                    Text(
                      cat.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 品种
                    Text(
                      cat.breed.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // TNR 徽章
                    TnrBadge(status: cat.tnrStatus, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据毛色获取背景色
  Color _getCatColor() {
    switch (cat.color.name) {
      case 'orange':
        return const Color(0xFFFFF3E0);
      case 'black':
        return const Color(0xFF424242);
      case 'white':
        return const Color(0xFFF5F5F5);
      case 'tabby':
        return const Color(0xFFE8D5B7);
      case 'calico':
        return const Color(0xFFFFE0B2);
      case 'tuxedo':
        return const Color(0xFF37474F);
      case 'gray':
        return const Color(0xFF9E9E9E);
      case 'cream':
        return const Color(0xFFFFF8E1);
      case 'tortoiseshell':
        return const Color(0xFFD7CCC8);
      default:
        return AppColors.lightCard;
    }
  }

  /// 根据品种获取代表 emoji
  String _getCatEmoji() {
    return '🐱';
  }
}
