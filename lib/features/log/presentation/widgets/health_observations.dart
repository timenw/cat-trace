import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/health_status.dart';

/// 健康观察组件
class HealthObservations extends StatefulWidget {
  final HealthStatus? selectedHealthStatus;
  final int spiritScore;
  final int furScore;
  final bool hasInjury;
  final String injuryDescription;
  final String weightEstimate;
  final Function(HealthStatus?)? onHealthStatusChanged;
  final Function(int)? onSpiritScoreChanged;
  final Function(int)? onFurScoreChanged;
  final Function(bool)? onHasInjuryChanged;
  final Function(String)? onInjuryDescriptionChanged;
  final Function(String)? onWeightChanged;

  const HealthObservations({
    super.key,
    this.selectedHealthStatus,
    this.spiritScore = 3,
    this.furScore = 3,
    this.hasInjury = false,
    this.injuryDescription = '',
    this.weightEstimate = '',
    this.onHealthStatusChanged,
    this.onSpiritScoreChanged,
    this.onFurScoreChanged,
    this.onHasInjuryChanged,
    this.onInjuryDescriptionChanged,
    this.onWeightChanged,
  });

  @override
  State<HealthObservations> createState() => _HealthObservationsState();
}

class _HealthObservationsState extends State<HealthObservations> {
  final _injuryController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  static const _healthStatuses = [
    {'key': 'excellent', 'label': '非常好', 'emoji': '😻', 'color': 0xFF4CAF50},
    {'key': 'good', 'label': '良好', 'emoji': '😺', 'color': 0xFF4CAF50},
    {'key': 'fair', 'label': '一般', 'emoji': '🐱', 'color': 0xFFFF9800},
    {'key': 'poor', 'label': '较差', 'emoji': '😿', 'color': 0xFFE57373},
    {'key': 'critical', 'label': '危急', 'emoji': '🙀', 'color': 0xFFE57373},
  ];

  String get _healthStatusKey =>
      widget.selectedHealthStatus?.name ?? 'good';

  @override
  void initState() {
    super.initState();
    _injuryController.text = widget.injuryDescription;
    _weightController.text = widget.weightEstimate;
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
            final isSelected = _healthStatusKey == status['key'];
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
              selectedColor: Color(status['color'] as int).withAlpha(40),
              onSelected: (selected) {
                if (selected) {
                  final hs = HealthStatus.values.firstWhere(
                    (e) => e.name == status['key'],
                    orElse: () => HealthStatus.good,
                  );
                  widget.onHealthStatusChanged?.call(hs);
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
          score: widget.spiritScore,
          labels: const ['很差', '较差', '一般', '良好', '非常好'],
          onChanged: (score) => widget.onSpiritScoreChanged?.call(score),
        ),
        const SizedBox(height: 16),

        // 毛发状态评分
        Text('毛发状态 (1-5)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _buildScoreSelector(
          score: widget.furScore,
          labels: const ['很差', '较差', '一般', '良好', '非常好'],
          onChanged: (score) => widget.onFurScoreChanged?.call(score),
        ),
        const SizedBox(height: 16),

        // 伤病记录
        Row(
          children: [
            Checkbox(
              value: widget.hasInjury,
              onChanged: (value) =>
                  widget.onHasInjuryChanged?.call(value ?? false),
            ),
            const Text('有伤病/异常'),
          ],
        ),
        if (widget.hasInjury) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _injuryController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: '描述伤病情况（位置、严重程度等）...',
            ),
            onChanged: (value) =>
                widget.onInjuryDescriptionChanged?.call(value),
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
          onChanged: (value) => widget.onWeightChanged?.call(value),
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
