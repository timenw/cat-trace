import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 健康观察组件
class HealthObservations extends StatefulWidget {
  final Function(Map<String, dynamic> data) onChanged;

  const HealthObservations({super.key, required this.onChanged});

  @override
  State<HealthObservations> createState() => _HealthObservationsState();
}

class _HealthObservationsState extends State<HealthObservations> {
  String _healthStatus = 'good';
  int _spiritScore = 3;
  int _furScore = 3;
  bool _hasInjury = false;
  final _injuryController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  final _healthStatuses = const [
    {'key': 'excellent', 'label': '非常好', 'emoji': '😻', 'color': AppColors.success},
    {'key': 'good', 'label': '良好', 'emoji': '😺', 'color': AppColors.success},
    {'key': 'fair', 'label': '一般', 'emoji': '🐱', 'color': AppColors.warning},
    {'key': 'poor', 'label': '较差', 'emoji': '😿', 'color': AppColors.error},
    {'key': 'critical', 'label': '危急', 'emoji': '🙀', 'color': AppColors.error},
  ];

  void _notifyChange() {
    widget.onChanged({
      'healthStatus': _healthStatus,
      'spiritScore': _spiritScore,
      'furScore': _furScore,
      'hasInjury': _hasInjury,
      'injuryDescription': _injuryController.text,
      'weightEstimate': _weightController.text.isEmpty ? null : double.tryParse(_weightController.text),
      'notes': _notesController.text,
    });
  }

  @override
  void dispose() {
    _injuryController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 整体健康状态
        Text('整体健康状态', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _healthStatuses.map((status) {
            final isSelected = _healthStatus == status['key'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status['emoji']! as String, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(status['label']! as String),
                ],
              ),
              selected: isSelected,
              selectedColor: (status['color'] as Color).withAlpha(40),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _healthStatus = status['key']! as String);
                  _notifyChange();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 精神状态评分
        Text('精神状态 (1-5)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _buildScoreSelector(
          score: _spiritScore,
          labels: const ['很差', '较差', '一般', '良好', '非常好'],
          onChanged: (score) {
            setState(() => _spiritScore = score);
            _notifyChange();
          },
        ),
        const SizedBox(height: 16),

        // 毛发状态评分
        Text('毛发状态 (1-5)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _buildScoreSelector(
          score: _furScore,
          labels: const ['很差', '较差', '一般', '良好', '非常好'],
          onChanged: (score) {
            setState(() => _furScore = score);
            _notifyChange();
          },
        ),
        const SizedBox(height: 16),

        // 伤病记录
        Row(
          children: [
            Checkbox(
              value: _hasInjury,
              onChanged: (value) {
                setState(() => _hasInjury = value ?? false);
                _notifyChange();
              },
            ),
            const Text('有伤病/异常'),
          ],
        ),
        if (_hasInjury) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _injuryController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: '描述伤病情况（位置、严重程度等）...',
            ),
            onChanged: (_) => _notifyChange(),
          ),
        ],
        const SizedBox(height: 16),

        // 体重估算
        Text('体重估算 (kg)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '例如: 4.5',
            suffixText: 'kg',
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),

        // 备注
        Text('观察备注', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '记录其他观察到的细节...',
          ),
          onChanged: (_) => _notifyChange(),
        ),

        // 异常提示
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠️ 如发现严重伤病或异常情况，建议联系专业志愿者或动物医院。',
                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSelector({
    required int score,
    required List<String> labels,
    required Function(int) onChanged,
  }) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = score >= value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.lightDivider,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (value == score)
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
