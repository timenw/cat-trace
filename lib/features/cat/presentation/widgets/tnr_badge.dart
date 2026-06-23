import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/enums/tnr_status.dart';

/// TNR 状态徽章
///
/// 用于显示猫咪的 TNR（捕捉-绝育-放归）状态。
/// 支持标准模式和紧凑模式。
class TnrBadge extends StatelessWidget {
  /// TNR 状态
  final TnrStatus status;

  /// 是否使用紧凑模式（用于卡片等空间受限的场景）
  final bool compact;

  const TnrBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: _getColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(_getIcon(), size: 14, color: _getColor()),
            const SizedBox(width: 4),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              color: _getColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 根据状态获取对应颜色
  Color _getColor() {
    switch (status) {
      case TnrStatus.none:
        return AppColors.tnrNone;
      case TnrStatus.earTip:
        return AppColors.tnrEarTip;
      case TnrStatus.neutered:
        return AppColors.tnrNeutered;
    }
  }

  /// 根据状态获取对应图标
  IconData _getIcon() {
    switch (status) {
      case TnrStatus.none:
        return Icons.close;
      case TnrStatus.earTip:
        return Icons.content_cut;
      case TnrStatus.neutered:
        return Icons.check_circle;
    }
  }
}
