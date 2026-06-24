import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/enums/feed_type.dart';
import '../../domain/entities/log_entity.dart' show FeedAmount;

/// 投喂模板组件 — 快速记录投喂
class FeedTemplate extends ConsumerStatefulWidget {
  final FeedType? selectedFeedType;
  final FeedAmount? selectedFeedAmount;
  final Function(FeedType?)? onFeedTypeChanged;
  final Function(FeedAmount?)? onFeedAmountChanged;

  const FeedTemplate({
    super.key,
    this.selectedFeedType,
    this.selectedFeedAmount,
    this.onFeedTypeChanged,
    this.onFeedAmountChanged,
  });

  @override
  ConsumerState<FeedTemplate> createState() => _FeedTemplateState();
}

class _FeedTemplateState extends ConsumerState<FeedTemplate> {
  final _notesController = TextEditingController();

  static final _feedTypes = [
    {'key': 'dryFood', 'label': '干粮', 'icon': '🍚', 'enum': FeedType.dryFood},
    {'key': 'wetFood', 'label': '湿粮', 'icon': '🥫', 'enum': FeedType.wetFood},
    {'key': 'treat', 'label': '零食', 'icon': '🍤', 'enum': FeedType.treat},
    {'key': 'raw', 'label': '生骨肉', 'icon': '🍖', 'enum': FeedType.raw},
    {'key': 'milk', 'label': '羊奶', 'icon': '🥛', 'enum': FeedType.milk},
    {'key': 'other', 'label': '其他', 'icon': '🍽️', 'enum': FeedType.other},
  ];

  static final _feedAmounts = [
    {'key': 'small', 'label': '少量', 'desc': '约10-20g', 'enum': FeedAmount.small},
    {'key': 'medium', 'label': '适量', 'desc': '约30-50g', 'enum': FeedAmount.medium},
    {'key': 'large', 'label': '大量', 'desc': '约60g以上', 'enum': FeedAmount.large},
  ];

  String get _selectedTypeKey =>
      widget.selectedFeedType?.name ?? 'dryFood';
  String get _selectedAmountKey =>
      widget.selectedFeedAmount?.name ?? 'medium';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 食物类型选择
        Text('食物类型', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _feedTypes.map((type) {
            final isSelected = _selectedTypeKey == type['key'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(type['label']!),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  widget.onFeedTypeChanged?.call(type['enum'] as FeedType);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 投喂量选择
        Text('投喂量', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: _feedAmounts.map((amount) {
            final isSelected = _selectedAmountKey == amount['key'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(amount['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(amount['desc']!, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onFeedAmountChanged?.call(amount['enum'] as FeedAmount);
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 备注
        Text('备注', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '记录猫咪的进食情况、偏好等...',
          ),
        ),
        const SizedBox(height: 16),

        // 科学建议
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 建议：少量多次投喂，避免一次性投放过多食物。定时清理剩余食物，保持环境清洁。',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
