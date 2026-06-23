import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../domain/entities/log_entity.dart';

/// 日志卡片组件
class LogCard extends StatelessWidget {
  final LogEntity log;
  final VoidCallback? onTap;

  const LogCard({super.key, required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 类型图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor().withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_getTypeEmoji(), style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTitle(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          log.recordedAt.formatFriendly(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.lightTextHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeEmoji() {
    switch (log.type) {
      case LogType.feed:
        return '🍖';
      case LogType.health:
        return '💊';
      case LogType.note:
        return '📝';
    }
  }

  Color _getTypeColor() {
    switch (log.type) {
      case LogType.feed:
        return AppColors.primary;
      case LogType.health:
        return AppColors.secondary;
      case LogType.note:
        return AppColors.accent;
    }
  }

  String _getTitle() {
    switch (log.type) {
      case LogType.feed:
        return '投喂记录';
      case LogType.health:
        return '健康观察';
      case LogType.note:
        return '观察笔记';
    }
  }

  String _getSubtitle() {
    switch (log.type) {
      case LogType.feed:
        return log.feedType?.displayName ?? '未知食物';
      case LogType.health:
        return log.healthStatus?.displayName ?? '未知状态';
      case LogType.note:
        return log.notes ?? '无内容';
    }
  }
}
