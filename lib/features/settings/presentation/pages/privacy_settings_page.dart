import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/permission_utils.dart';
import '../../core/services/notification_service.dart';

/// 隐私设置页面
/// 
/// 管理数据加密、位置、水印等隐私相关选项
class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool _locationRecordingEnabled = false;
  bool _autoWatermarkEnabled = true;
  bool _encryptBackupEnabled = false;
  bool _biometricLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: '数据保护'),
          SwitchListTile(
            title: const Text('自动水印'),
            subtitle: const Text('在照片上添加时间和随机ID水印'),
            value: _autoWatermarkEnabled,
            onChanged: (v) => setState(() => _autoWatermarkEnabled = v),
          ),
          SwitchListTile(
            title: const Text('加密备份'),
            subtitle: const Text('云备份数据加密存储'),
            value: _encryptBackupEnabled,
            onChanged: (v) => setState(() => _encryptBackupEnabled = v),
          ),
          SwitchListTile(
            title: const Text('生物识别锁'),
            subtitle: const Text('使用指纹/面容解锁App'),
            value: _biometricLockEnabled,
            onChanged: (v) => setState(() => _biometricLockEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: '位置服务'),
          SwitchListTile(
            title: const Text('位置记录'),
            subtitle: const Text('记录发现猫咪的区域位置（模糊化）'),
            value: _locationRecordingEnabled,
            onChanged: (v) async {
              if (v) {
                final result = await PermissionUtils.requestLocationPermission();
                if (result != PermissionResult.granted) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('需要位置权限才能使用此功能')),
                  );
                  return;
                }
              }
              setState(() => _locationRecordingEnabled = v);
            },
          ),
          const _SectionHeader(title: '通知权限'),
          FutureBuilder<bool>(
            future: PermissionUtils.isNotificationGranted(),
            builder: (context, snapshot) {
              final granted = snapshot.data ?? false;
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('通知权限'),
                subtitle: Text(granted ? '已授予' : '点击授权'),
                trailing: Icon(granted ? Icons.check : Icons.chevron_right),
                onTap: () async {
                  final service = NotificationService();
                  final result = await service.requestPermission();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ? '权限授予成功' : '权限授予失败')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}