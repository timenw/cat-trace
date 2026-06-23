import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 隐私与安全
          _SectionHeader(title: '隐私与安全'),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: '隐私设置',
            subtitle: '数据加密、水印、位置',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: '备份与恢复',
            subtitle: '本地备份、云备份',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: '导出数据',
            subtitle: '导出所有档案为 PDF/Zip',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: '清空所有数据',
            subtitle: '删除所有猫咪档案和记录',
            onTap: () {},
            isDestructive: true,
          ),

          const Divider(),

          // 通用
          _SectionHeader(title: '通用'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: '通知设置',
            subtitle: '投喂提醒、健康观察提醒',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: '主题',
            subtitle: '浅色/深色模式',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: '语言',
            subtitle: '中文/English',
            onTap: () {},
          ),

          const Divider(),

          // TNR
          _SectionHeader(title: 'TNR'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'TNR 科普',
            subtitle: '了解 TNR 的意义和方法',
            onTap: () => context.go(RoutePaths.tnrGuide),
          ),
          _SettingsTile(
            icon: Icons.phone_outlined,
            title: '联系方式',
            subtitle: '本地动保组织/绝育医院',
            onTap: () {},
          ),

          const Divider(),

          // 关于
          _SectionHeader(title: '关于'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: '隐私政策',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.warning_amber_outlined,
            title: '免责声明',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: '关于猫迹',
            subtitle: '版本 1.0.0',
            onTap: () {},
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? AppColors.error : null),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
