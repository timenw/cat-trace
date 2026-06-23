import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../domain/entities/log_entity.dart';
import '../../../domain/enums/feed_type.dart';
import '../../../domain/enums/health_status.dart';
import '../../../domain/enums/log_type.dart';
import '../../data/models/log_dto.dart';
import '../widgets/feed_template.dart';
import '../widgets/health_observations.dart';

/// 添加日志页面
///
/// 提供三种日志类型的录入界面：
/// - 投喂记录：记录食物类型、投喂量等信息
/// - 健康观察：记录健康状态、精神/毛发评分、伤病情况等
/// - 观察笔记：记录一般性观察内容和备注
///
/// 用户可以通过顶部的 [SegmentedButton] 切换日志类型，
/// 页面会根据所选类型动态显示对应的表单组件。
class AddLogPage extends ConsumerStatefulWidget {
  /// 关联的猫咪 ID
  final int catId;

  const AddLogPage({super.key, required this.catId});

  @override
  ConsumerState<AddLogPage> createState() => _AddLogPageState();
}

class _AddLogPageState extends ConsumerState<AddLogPage> {
  /// 表单键，用于表单验证
  final _formKey = GlobalKey<FormState>();

  /// 当前选中的日志类型
  LogType _selectedType = LogType.feed;

  /// 记录时间
  DateTime _recordedAt = DateTime.now();

  /// 备注文本控制器
  final _notesController = TextEditingController();

  /// 位置提示文本控制器
  final _locationController = TextEditingController();

  /// 是否正在提交
  bool _isLoading = false;

  // ====== 投喂相关状态 ======
  FeedType? _selectedFeedType;
  FeedAmount? _selectedFeedAmount;

  // ====== 健康观察相关状态 ======
  HealthStatus? _selectedHealthStatus;
  int _spiritScore = 3; // 精神状态评分（1-5）
  int _furScore = 3; // 毛发状态评分（1-5）
  bool _hasInjury = false;
  final _injuryDescController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    _injuryDescController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加日志'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitLog,
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日志类型选择器
              _buildLogTypeSelector(),
              const SizedBox(height: 24),

              // 记录时间选择
              _buildRecordedAtPicker(),
              const SizedBox(height: 24),

              // 根据日志类型显示不同的表单
              _buildFormByType(),
              const SizedBox(height: 24),

              // 位置提示
              _buildLocationField(),
              const SizedBox(height: 16),

              // 备注
              _buildNotesField(),
              const SizedBox(height: 32),

              // 提交按钮
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建日志类型选择器
  Widget _buildLogTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日志类型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<LogType>(
          segments: const [
            ButtonSegment(
              value: LogType.feed,
              label: Text('投喂'),
              icon: Icon(Icons.restaurant, size: 18),
            ),
            ButtonSegment(
              value: LogType.health,
              label: Text('健康'),
              icon: Icon(Icons.health_and_safety, size: 18),
            ),
            ButtonSegment(
              value: LogType.note,
              label: Text('笔记'),
              icon: Icon(Icons.note, size: 18),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (selected) {
            setState(() {
              _selectedType = selected.first;
              // 切换类型时重置相关状态
              _resetTypeSpecificState();
            });
          },
        ),
      ],
    );
  }

  /// 构建记录时间选择器
  Widget _buildRecordedAtPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '记录时间',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickRecordedAt,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 12),
                Text(
                  _formatDateTime(_recordedAt),
                  style: const TextStyle(fontSize: 15),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 根据日志类型构建对应的表单
  Widget _buildFormByType() {
    switch (_selectedType) {
      case LogType.feed:
        return FeedTemplate(
          selectedFeedType: _selectedFeedType,
          selectedFeedAmount: _selectedFeedAmount,
          onFeedTypeChanged: (type) {
            setState(() => _selectedFeedType = type);
          },
          onFeedAmountChanged: (amount) {
            setState(() => _selectedFeedAmount = amount);
          },
        );
      case LogType.health:
        return HealthObservations(
          selectedHealthStatus: _selectedHealthStatus,
          spiritScore: _spiritScore,
          furScore: _furScore,
          hasInjury: _hasInjury,
          injuryDescription: _injuryDescController.text,
          weightEstimate: _weightController.text,
          onHealthStatusChanged: (status) {
            setState(() => _selectedHealthStatus = status);
          },
          onSpiritScoreChanged: (score) {
            setState(() => _spiritScore = score);
          },
          onFurScoreChanged: (score) {
            setState(() => _furScore = score);
          },
          onHasInjuryChanged: (value) {
            setState(() {
              _hasInjury = value;
              if (!value) {
                _injuryDescController.clear();
              }
            });
          },
          onInjuryDescriptionChanged: (desc) {
            _injuryDescController.text = desc;
          },
          onWeightChanged: (weight) {
            _weightController.text = weight;
          },
        );
      case LogType.note:
        return const SizedBox.shrink(); // 笔记类型只需备注字段
    }
  }

  /// 构建位置提示输入框
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '位置（可选）',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: '如：东区花坛旁',
            prefixIcon: Icon(Icons.location_on_outlined, size: 20),
          ),
        ),
      ],
    );
  }

  /// 构建备注输入框
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '备注（可选）',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '补充备注信息...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Icon(Icons.notes, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _submitLog,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('保存日志'),
      ),
    );
  }

  /// 选择记录时间
  Future<void> _pickRecordedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_recordedAt),
      );
      if (time != null && mounted) {
        setState(() {
          _recordedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// 重置类型相关状态
  void _resetTypeSpecificState() {
    _selectedFeedType = null;
    _selectedFeedAmount = null;
    _selectedHealthStatus = null;
    _spiritScore = 3;
    _furScore = 3;
    _hasInjury = false;
    _injuryDescController.clear();
    _weightController.clear();
  }

  /// 提交日志
  Future<void> _submitLog() async {
    // 基本验证
    if (_selectedType == LogType.feed && _selectedFeedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择食物类型'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 构建 LogDto
      final dto = LogDto(
        catId: widget.catId,
        type: _selectedType,
        recordedAt: _recordedAt,
        feedType: _selectedFeedType,
        feedAmount: _selectedFeedAmount,
        healthStatus: _selectedHealthStatus,
        spiritScore: _selectedType == LogType.health ? _spiritScore : null,
        furScore: _selectedType == LogType.health ? _furScore : null,
        hasInjury: _selectedType == LogType.health ? _hasInjury : null,
        injuryDescription: _selectedType == LogType.health && _hasInjury
            ? _injuryDescController.text
            : null,
        weightEstimate: _selectedType == LogType.health &&
                _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        locationHint: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
      );

      // TODO: 通过 repository 保存日志
      // final entity = dto.toEntity();
      // await ref.read(logRepositoryProvider.notifier).addLog(entity);
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟保存

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日志保存成功'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
