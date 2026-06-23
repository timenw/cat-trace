import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 隐私设置组件
class PrivacySettings extends StatelessWidget {
  final bool locationEnabled;
  final bool watermarkEnabled;
  final Function(bool) onLocationChanged;
  final Function(bool) onWatermarkChanged;

  const PrivacySettings({
    super.key,
    required this.locationEnabled,
    required this.watermarkEnabled,
    required this.onLocationChanged,
    required this.onWatermarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('隐私设置', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('记录位置'),
          subtitle: const Text('模糊处理，仅本地使用'),
          value: locationEnabled,
          onChanged: onLocationChanged,
          secondary: const Icon(Icons.location_on_outlined),
        ),
        SwitchListTile(
          title: const Text('照片水印'),
          subtitle: const Text('自动添加时间戳和随机ID'),
          value: watermarkEnabled,
          onChanged: onWatermarkChanged,
          secondary: const Icon(Icons.watermark),
        ),
      ],
    );
  }
}

/// 备份设置组件
class BackupSettings extends StatelessWidget {
  final bool backupEnabled;
  final DateTime? lastBackupTime;
  final Function(bool) onBackupChanged;
  final VoidCallback onBackupNow;
  final VoidCallback onRestore;

  const BackupSettings({
    super.key,
    required this.backupEnabled,
    required this.lastBackupTime,
    required this.onBackupChanged,
    required this.onBackupNow,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('备份与恢复', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('自动备份'),
          subtitle: lastBackupTime != null
              ? Text('上次备份: ${lastBackupTime!.formatFriendly()}')
              : const Text('从未备份'),
          value: backupEnabled,
          onChanged: onBackupChanged,
          secondary: const Icon(Icons.backup_outlined),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBackupNow,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('立即备份'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('恢复数据'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 数据管理组件
class DataManagement extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onClearAll;
  final int totalCats;
  final int totalLogs;
  final int totalPhotos;
  final String storageSize;

  const DataManagement({
    super.key,
    required this.onExport,
    required this.onClearAll,
    required this.totalCats,
    required this.totalLogs,
    required this.totalPhotos,
    required this.storageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('数据管理', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        // 数据统计
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StatRow(icon: '🐱', label: '猫咪档案', value: '$totalCats 只'),
                const Divider(),
                _StatRow(icon: '📝', label: '日志记录', value: '$totalLogs 条'),
                const Divider(),
                _StatRow(icon: '📷', label: '照片', value: '$totalPhotos 张'),
                const Divider(),
                _StatRow(icon: '💾', label: '存储空间', value: storageSize),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 操作按钮
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.download_outlined),
                label: const Text('导出数据'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showClearConfirm(context),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                label: const Text('清空数据'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onClearAll();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(label),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// 关于组件
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('关于', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '猫迹 CatTrace',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('版本 1.0.0'),
                const SizedBox(height: 8),
                const Text(
                  '一款专为爱猫人士设计的流浪猫记录与收集软件。\n愿每一只猫都被温柔以待 🐱',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
