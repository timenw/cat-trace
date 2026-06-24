import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';

/// 事件列表组件
///
/// 展示指定日期的事件列表，每个事件以卡片形式呈现。
/// 支持按事件类型显示不同颜色的图标和标签。
///
/// 使用示例：
/// ```dart
/// EventList(
///   events: dayEvents,
///   date: selectedDate,
/// )
/// ```
class EventList extends StatelessWidget {
  /// 事件列表
  final List<dynamic> events;

  /// 日期
  final DateTime date;

  /// 事件点击回调
  final ValueChanged<dynamic>? onEventTap;

  /// 是否正在加载
  final bool isLoading;

  const EventList({
    super.key,
    required this.events,
    required this.date,
    this.onEventTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: '当天暂无记录',
        subtitle: '选择其他日期查看\n或添加新的猫咪日志',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====== 日期标题 ======
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('M 月 d 日 EEEE').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${events.length} 条记录',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // ====== 事件卡片列表 ======
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(context, event, index);
          },
        ),
      ],
    );
  }

  /// 构建单个事件卡片
  Widget _buildEventCard(BuildContext context, dynamic event, int index) {
    // 从 event 中提取类型信息
    final logType = _getLogType(event);
    final title = _getTitle(event);
    final description = _getDescription(event);
    final catName = _getCatName(event);
    final time = _getTime(event);
    final iconData = _getIcon(logType);
    final color = _getColor(logType);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onEventTap?.call(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              // 中间内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题 + 时间
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextHint,
                          ),
                        ),
                      ],
                    ),
                    if (catName != null && catName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // 右侧箭头
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.lightTextHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 从 event 获取日志类型
  dynamic _getLogType(dynamic event) {
    if (event == null) return null;
    // 如果是 LogEntity 类型
    try {
      return event.logType;
    } catch (_) {
      return null;
    }
  }

  /// 获取标题
  String _getTitle(dynamic event) {
    if (event == null) return '';
    try {
      return event.title ?? '';
    } catch (_) {
      return '日志记录';
    }
  }

  /// 获取描述
  String? _getDescription(dynamic event) {
    if (event == null) return null;
    try {
      return event.description;
    } catch (_) {
      return null;
    }
  }

  /// 获取猫咪名称
  String? _getCatName(dynamic event) {
    if (event == null) return null;
    try {
      return event.catName;
    } catch (_) {
      return null;
    }
  }

  /// 获取时间字符串
  String _getTime(dynamic event) {
    if (event == null) return '';
    try {
      final dt = event.date ?? event.recordedAt;
      if (dt is DateTime) {
        return DateFormat('HH:mm').format(dt);
      }
    } catch (_) {}
    return '';
  }

  /// 获取图标
  IconData _getIcon(dynamic logType) {
    if (logType == null) return Icons.note_rounded;
    try {
      switch (logType.name) {
        case 'feed':
          return Icons.restaurant_rounded;
        case 'health':
          return Icons.favorite_rounded;
        case 'note':
          return Icons.note_alt_rounded;
        default:
          return Icons.note_rounded;
      }
    } catch (_) {
      return Icons.note_rounded;
    }
  }

  /// 获取颜色
  Color _getColor(dynamic logType) {
    if (logType == null) return AppColors.primary;
    try {
      switch (logType.name) {
        case 'feed':
          return AppColors.success;
        case 'health':
          return AppColors.info;
        case 'note':
          return AppColors.warning;
        default:
          return AppColors.primary;
      }
    } catch (_) {
      return AppColors.primary;
    }
  }
}
