import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';

/// 成就页面
class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成就'),
        centerTitle: true,
      ),
      body: const EmptyState(
        icon: '🏆',
        title: '成就系统',
        subtitle: '记录猫咪收集进度，解锁成就徽章\n即将上线',
      ),
    );
  }
}
