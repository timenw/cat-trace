import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// 投喂模板组件 — 快速记录投喂
class FeedTemplate extends ConsumerStatefulWidget {
  final Function(String feedType, String feedAmount, String? notes) onSave;

  const FeedTemplate({super.key, required this.onSave});

  @override
  ConsumerState<FeedTemplate> createState() => _FeedTemplateState();
}

class _FeedTemplateState extends ConsumerState<FeedTemplate> {
  String _selectedType = 'dry_food';
  String _selectedAmount = 'medium';
  final _notesController = TextEditingController();

  final _feedTypes = const [
    {'key': 'dry_food', 'label': '干粮', 'icon': '🍚'},
    {'key': 'wet_food', 'label': '湿粮', 'icon': '🥫'},
    {'key': 'treat', 'label': '零食', 'icon': '🍤'},
    {'key': 'raw', 'label': '生骨肉', 'icon': '🍖'},
    {'key': 'milk', 'label': '羊奶', 'icon': '🥛'},
    {'key': 'other', 'label': '其他', 'icon': '🍽️'},
  ];

  final _feedAmounts = const [
    {'key': 'small', 'label': '少量', 'desc': '约10-20g'},
    {'key': 'medium', 'label': '适量', 'desc': '约30-50g'},
    {'key': 'large', 'label': '大量', 'desc': '约60g以上'},
  ];

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
            final isSelected = _selectedType == type['key'];
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
                if (selected) setState(() => _selectedType = type['key']!);
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
            final isSelected = _selectedAmount == amount['key'];
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
                    if (selected) setState(() => _selectedAmount = amount['key']!);
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

        // 保存按钮
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              widget.onSave(
                _selectedType,
                _selectedAmount,
                _notesController.text.isEmpty ? null : _notesController.text,
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('保存投喂记录'),
          ),
        ),

        // 科学建议
        const SizedBox(height: 12),
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
