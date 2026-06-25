import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// 提醒设置组件
/// 
/// 用于设置投喂提醒和健康观察提醒
class ReminderSettingWidget extends ConsumerStatefulWidget {
  final int catId;
  final bool initialEnabled;
  final int? initialFeedHour;
  final int? initialFeedMinute;
  final int? initialHealthHour;
  final int? initialHealthMinute;

  const ReminderSettingWidget({
    super.key,
    required this.catId,
    this.initialEnabled = false,
    this.initialFeedHour,
    this.initialFeedMinute,
    this.initialHealthHour,
    this.initialHealthMinute,
  });

  @override
  ConsumerState<ReminderSettingWidget> createState() => _ReminderSettingWidgetState();
}

class _ReminderSettingWidgetState extends ConsumerState<ReminderSettingWidget> {
  bool _feedReminderEnabled = false;
  bool _healthReminderEnabled = false;
  TimeOfDay? _feedTime;
  TimeOfDay? _healthTime;

  @override
  void initState() {
    super.initState();
    _feedReminderEnabled = widget.initialEnabled && widget.initialFeedHour != null;
    _healthReminderEnabled = widget.initialEnabled && widget.initialHealthHour != null;
    _feedTime = widget.initialFeedHour != null
        ? TimeOfDay(hour: widget.initialFeedHour!, minute: widget.initialFeedMinute ?? 0)
        : null;
    _healthTime = widget.initialHealthHour != null
        ? TimeOfDay(hour: widget.initialHealthHour!, minute: widget.initialHealthMinute ?? 0)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  '提醒设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('投喂提醒'),
              subtitle: Text(_feedTime != null 
                  ? '每天 ${_feedTime!.format(context)} 提醒' 
                  : '设置后可获得投喂记录提醒'),
              value: _feedReminderEnabled,
              onChanged: (v) => setState(() => _feedReminderEnabled = v),
            ),
            if (_feedReminderEnabled) ...[
              const SizedBox(height: 8),
              _buildTimePicker(
                label: '提醒时间',
                time: _feedTime,
                onPicked: (t) => setState(() => _feedTime = t),
              ),
            ],
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('健康观察提醒'),
              subtitle: Text(_healthTime != null
                  ? '每天 ${_healthTime!.format(context)} 提醒'
                  : '定期记录猫咪健康状态'),
              value: _healthReminderEnabled,
              onChanged: (v) => setState(() => _healthReminderEnabled = v),
            ),
            if (_healthReminderEnabled) ...[
              const SizedBox(height: 8),
              _buildTimePicker(
                label: '提醒时间',
                time: _healthTime,
                onPicked: (t) => setState(() => _healthTime = t),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '提示：提醒功能基于本地通知，无需网络连接',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay> onPicked,
  }) {
    return ListTile(
      title: Text(label),
      trailing: Text(time?.format(context) ?? '未设置'),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  Map<String, dynamic> get settings => {
        'reminderEnabled': _feedReminderEnabled || _healthReminderEnabled,
        'feedReminderHour': _feedReminderEnabled ? _feedTime?.hour : null,
        'feedReminderMinute': _feedReminderEnabled ? _feedTime?.minute : null,
        'healthReminderHour': _healthReminderEnabled ? _healthTime?.hour : null,
        'healthReminderMinute': _healthReminderEnabled ? _healthTime?.minute : null,
      };
}