import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/isar_database.dart';
import '../domain/usecases/get_calendar_events.dart';
import '../../log/domain/repositories/log_repository.dart';
import '../../log/data/datasources/log_local_datasource.dart';
import '../../log/data/repositories/log_repository_impl.dart';

part 'calendar_providers.g.dart';

// ============================================================================
// 数据源 & 仓库 Provider
// ============================================================================

/// 日志仓库 Provider（日历页面复用日志数据）
final logRepositoryProvider = Provider<LogRepository>((ref) {
  final datasource = ref.watch(logLocalDataSourceProvider);
  return LogRepositoryImpl(datasource);
});

final logLocalDataSourceProvider = Provider<LogLocalDataSource>((ref) {
  return LogLocalDataSource(IsarDatabase.instance);
});

// ============================================================================
// UseCase Provider
// ============================================================================

/// 获取日历事件 UseCase Provider
@riverpod
GetCalendarEvents getCalendarEvents(GetCalendarEventsRef ref) {
  return GetCalendarEvents(IsarDatabase.instance);
}

// ============================================================================
// 日历状态管理 Provider
// ============================================================================

/// 当前选中的日期 StateProvider
///
/// 默认值为今天。用户点击日历中的某一天时更新。
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 当前显示的年月 StateProvider
///
/// 用于日历视图的月份导航。
final currentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// 猫咪筛选 StateProvider（null 表示所有猫咪）
final calendarCatFilterProvider = StateProvider<int?>((ref) => null);

// ============================================================================
// 日历事件 FutureProvider
// ============================================================================

/// 选中日期的事件列表 Provider
///
/// 根据 selectedDateProvider 和 calendarCatFilterProvider 获取当天的事件。
final dayEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final usecase = ref.watch(getCalendarEventsProvider);
  final date = ref.watch(selectedDateProvider);
  final catId = ref.watch(calendarCatFilterProvider);
  return usecase.getDayEvents(date, catId: catId);
});

/// 当前月份的事件日期集合 Provider
///
/// 用于日历视图中标记有事件的日期。
final monthEventDatesProvider = FutureProvider<Set<String>>((ref) async {
  final usecase = ref.watch(getCalendarEventsProvider);
  final month = ref.watch(currentMonthProvider);
  final catId = ref.watch(calendarCatFilterProvider);

  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0);

  return usecase.getEventDates(
    startDate: startDate,
    endDate: endDate,
    catId: catId,
  );
});

/// 当前月份的事件列表 Provider
///
/// 获取当前显示月份的所有事件，用于事件列表视图。
final monthEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final usecase = ref.watch(getCalendarEventsProvider);
  final month = ref.watch(currentMonthProvider);
  final catId = ref.watch(calendarCatFilterProvider);

  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  return usecase(
    startDate: startDate,
    endDate: endDate,
    catId: catId,
  );
});

/// 切换月份的 ActionProvider
///
/// 返回一个函数，用于切换到上一个月或下一个月。
final switchMonthProvider = Provider<Function(int)>((ref) {
  return (int offset) {
    ref.read(currentMonthProvider.notifier).state = ref.read(currentMonthProvider).copyWith(
      month: ref.read(currentMonthProvider).month + offset,
    );
  };
});

/// 选择日期的 ActionProvider
///
/// 返回一个函数，用于选择特定日期。
final selectDateProvider = Provider<Function(DateTime)>((ref) {
  return (DateTime date) {
    ref.read(selectedDateProvider.notifier).state = date;
  };
});

/// 切换猫咪筛选的 ActionProvider
final toggleCatFilterProvider = Provider<Function(int?)>((ref) {
  return (int? catId) {
    ref.read(calendarCatFilterProvider.notifier).state = catId;
  };
});

/// 刷新日历数据的 ActionProvider
final refreshCalendarProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(dayEventsProvider);
    ref.invalidate(monthEventDatesProvider);
    ref.invalidate(monthEventsProvider);
  };
});
