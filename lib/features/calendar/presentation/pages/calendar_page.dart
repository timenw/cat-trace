import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';

/// 日历页面
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
        centerTitle: true,
      ),
      body: const EmptyState(
        icon: '📅',
        title: '日历视图',
        subtitle: '查看投喂和观察记录的时间线\n即将上线',
      ),
    );
  }
}
