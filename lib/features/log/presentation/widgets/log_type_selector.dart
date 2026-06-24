import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/log_type.dart';

/// 日志类型选择器组件
///
/// 提供三种日志类型的切换选择：投喂、健康观察、观察笔记。
/// 支持两种展示模式：
/// 1. [LogTypeSelectorMode.segmented] - 分段按钮模式（紧凑，适合顶部切换）
/// 2. [LogTypeSelectorMode.card] - 卡片模式（展开，适合表单内嵌）
///
/// 使用示例：
/// ```dart
/// // 分段按钮模式
/// LogTypeSelector(
///   selectedType: _selectedType,
///   mode: LogTypeSelectorMode.segmented,
///   onChanged: (type) => setState(() => _selectedType = type),
/// )
///
/// // 卡片模式
/// LogTypeSelector(
///   selectedType: _selectedType,
///   mode: LogTypeSelectorMode.card,
///   onChanged: (type) => setState(() => _selectedType = type),
/// )
/// ```
class LogTypeSelector extends StatelessWidget {
  /// 当前选中的日志类型
  final LogType selectedType;

  /// 展示模式（分段按钮 / 卡片）
  final LogTypeSelectorMode mode;

  /// 类型变化回调
  final ValueChanged<LogType> onChanged;

  const LogTypeSelector({
    super.key,
    required this.selectedType,
    this.mode = LogTypeSelectorMode.segmented,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case LogTypeSelectorMode.segmented:
        return _buildSegmentedMode(context);
      case LogTypeSelectorMode.card:
        return _buildCardMode(context);
    }
  }

  /// 构建分段按钮模式
  ///
  /// 使用 [SegmentedButton] 实现紧凑的三段式切换，
  /// 适合放置在页面顶部或 AppBar 下方。
  Widget _buildSegmentedMode(BuildContext context) {
    return SegmentedButton<LogType>(
      segments: [
        ButtonSegment(
          value: LogType.feed,
          label: const Text('投喂', style: TextStyle(fontSize: 13)),
          icon: const Icon(Icons.restaurant_rounded, size: 18),
        ),
        ButtonSegment(
          value: LogType.health,
          label: const Text('健康', style: TextStyle(fontSize: 13)),
          icon: const Icon(Icons.health_and_safety_rounded, size: 18),
        ),
        ButtonSegment(
          value: LogType.note,
          label: const Text('笔记', style: TextStyle(fontSize: 13)),
          icon: const Icon(Icons.note_rounded, size: 18),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (selected) {
        onChanged(selected.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        selectedBackgroundColor: AppColors.primary.withOpacity(0.15),
        selectedForegroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  /// 构建卡片模式
  ///
  /// 使用三个并排的卡片展示日志类型，
  /// 每个卡片包含图标、标题和简短描述，
  /// 选中时高亮显示。
  Widget _buildCardMode(BuildContext context) {
    return Row(
      children: LogType.values.map((type) {
        final isSelected = selectedType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildTypeCard(context, type, isSelected),
          ),
        );
      }).toList(),
    );
  }

  /// 构建单个类型卡片
  Widget _buildTypeCard(BuildContext context, LogType type, bool isSelected) {
    final config = _getTypeConfig(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => onChanged(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? config.color.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? config.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? config.color.withOpacity(0.15)
                      : AppColors.lightTextHint.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  size: 22,
                  color: isSelected ? config.color : AppColors.lightTextHint,
                ),
              ),
              const SizedBox(height: 8),
              // 标题
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? config.color : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              // 描述
              Text(
                config.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? config.color.withOpacity(0.7)
                      : AppColors.lightTextHint,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取日志类型的配置信息
  _LogTypeConfig _getTypeConfig(LogType type) {
    switch (type) {
      case LogType.feed:
        return _LogTypeConfig(
          color: AppColors.primary,
          icon: Icons.restaurant_rounded,
          description: '记录投喂',
        );
      case LogType.health:
        return _LogTypeConfig(
          color: AppColors.secondary,
          icon: Icons.health_and_safety_rounded,
          description: '健康检查',
        );
      case LogType.note:
        return _LogTypeConfig(
          color: AppColors.accent,
          icon: Icons.note_rounded,
          description: '观察笔记',
        );
    }
  }
}

/// 日志类型选择器展示模式
enum LogTypeSelectorMode {
  /// 分段按钮模式（紧凑）
  segmented,

  /// 卡片模式（展开）
  card,
}

/// 日志类型配置（内部辅助类）
class _LogTypeConfig {
  final Color color;
  final IconData icon;
  final String description;

  const _LogTypeConfig({
    required this.color,
    required this.icon,
    required this.description,
  });
}
