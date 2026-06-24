import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../presentation/providers/calendar_providers.dart';
import '../presentation/widgets/calendar_view.dart';
import '../presentation/widgets/event_list.dart';

/// 日历页面
///
/// 展示猫咪日志的日历视图，支持按月浏览和按日查看事件详情。
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthEventDates = ref.watch(monthEventDatesProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final dayEvents = ref.watch(dayEventsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ====== 顶部栏 ======
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '日历',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            actions: [
              // 筛选按钮
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => _showFilterDialog(context, ref),
                tooltip: '筛选',
              ),
            ],
          ),

          // ====== 日历视图 ======
          SliverToBoxAdapter(
            child: monthEventDates.when(
              data: (eventDates) {
                return CalendarView(
                  eventDates: eventDates,
                  currentMonth: currentMonth,
                  onDaySelected: (date) {
                    ref.read(selectedDateProvider.notifier).state = date;
                    // 滚动到事件列表
                    Future.microtask(() {
                      if (context.mounted) {
                        Scrollable.ensureVisible(
                          context.findRenderObject() as RenderBox,
                          duration: const Duration(milliseconds: 300),
                          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                        );
                      }
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('加载失败: $error')),
            ),
          ),

          // ====== 事件列表 ======
          SliverToBoxAdapter(
            child: dayEvents.when(
              data: (events) {
                return EventList(
                  events: events,
                  date: selectedDate,
                  onEventTap: (event) {
                    // 点击事件查看详情
                    _showEventDetail(context, event);
                  },
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (error, stack) => const EmptyState(
                icon: Icons.error_outline_rounded,
                title: '加载失败',
                subtitle: '请稍后重试',
              ),
            ),
          ),

          // ====== 底部留白 ======
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// 显示筛选对话框
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '筛选',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.pets_rounded),
                  title: const Text('所有猫咪'),
                  trailing: ref.watch(calendarCatFilterProvider) == null
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(calendarCatFilterProvider.notifier).state = null;
                    Navigator.pop(ctx);
                  },
                ),
                // 这里后续可以动态加载猫咪列表
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示事件详情
  void _showEventDetail(BuildContext context, dynamic event) {
    // TODO: 实现事件详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看事件详情: ${event.title}')),
    );
  }
}
