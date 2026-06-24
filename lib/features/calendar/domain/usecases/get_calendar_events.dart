import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/isar_database.dart';
import '../../../../core/database/schemas/log_schema.dart';
import '../../../../features/log/domain/entities/log_entity.dart';
import '../../../../features/log/domain/enums/log_type.dart';

part 'get_calendar_events.g.dart';

// ============================================================================
// 日历事件实体
// ============================================================================

/// 日历事件实体
///
/// 用于日历视图展示的事件，从 Log 数据聚合而来。
/// 每条日志记录对应一个日历事件。
class CalendarEvent {
  /// 事件 ID（对应日志 ID）
  final int id;

  /// 事件日期
  final DateTime date;

  /// 事件类型（投喂/观察/其他）
  final LogType logType;

  /// 事件标题
  final String title;

  /// 事件描述
  final String? description;

  /// 关联的猫咪 ID
  final int catId;

  /// 关联的猫咪名称（暂为空，后续可扩展）
  final String? catName;

  /// 是否在当天
  bool get isToday =>
      date.year == DateTime.now().year &&
      date.month == DateTime.now().month &&
      date.day == DateTime.now().day;

  CalendarEvent({
    required this.id,
    required this.date,
    required this.logType,
    required this.title,
    this.description,
    required this.catId,
    this.catName,
  });

  /// 从 LogEntity 创建 CalendarEvent
  factory CalendarEvent.fromLog(LogEntity log) {
    return CalendarEvent(
      id: log.id,
      date: log.recordedAt,
      logType: log.type,
      title: log.type.displayName,
      description: log.notes,
      catId: log.catId,
      catName: null, // LogEntity 暂无 catName 字段，后续可扩展
    );
  }

  /// 从 LogSchema 创建 CalendarEvent
  factory CalendarEvent.fromSchema(LogSchema schema) {
    return CalendarEvent(
      id: schema.id,
      date: schema.recordedAt,
      logType: schema.type,
      title: schema.type.displayName,
      description: schema.notes,
      catId: schema.catId,
      catName: null,
    );
  }
}

// ============================================================================
// UseCase
// ============================================================================

/// 获取日历事件 UseCase
///
/// 从日志数据中聚合出日历事件，支持按日期范围和猫咪筛选。
class GetCalendarEvents {
  final Isar _isar;

  const GetCalendarEvents(this._isar);

  /// 获取指定日期范围内的事件
  ///
  /// [startDate] 起始日期（包含）
  /// [endDate] 结束日期（包含）
  /// [catId] 可选的猫咪 ID 筛选
  Future<List<CalendarEvent>> call({
    required DateTime startDate,
    required DateTime endDate,
    int? catId,
  }) async {
    final collection = _isar.collection<LogSchema>();

    // 获取该日期范围内的日志
    final logs = catId != null
        ? await collection
            .filter()
            .catIdEqualTo(catId)
            .recordedAtGreaterThan(startDate)
            .recordedAtLessThan(endDate)
            .sortByRecordedAtDesc()
            .findAll()
        : await collection
            .filter()
            .recordedAtGreaterThan(startDate)
            .recordedAtLessThan(endDate)
            .sortByRecordedAtDesc()
            .findAll();

    return logs.map(CalendarEvent.fromSchema).toList();
  }

  /// 获取某个月份的所有事件
  Future<List<CalendarEvent>> getMonthEvents(
    int year,
    int month, {
    int? catId,
  }) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    return call(startDate: startDate, endDate: endDate, catId: catId);
  }

  /// 获取某一天的所有事件
  Future<List<CalendarEvent>> getDayEvents(
    DateTime date, {
    int? catId,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return call(startDate: start, endDate: end, catId: catId);
  }

  /// 获取有事件的日期列表（用于日历标记）
  ///
  /// 返回一组日期字符串（yyyy-MM-dd），表示哪些天有事件记录。
  Future<Set<String>> getEventDates({
    required DateTime startDate,
    required DateTime endDate,
    int? catId,
  }) async {
    final collection = _isar.collection<LogSchema>();

    final logs = catId != null
        ? await collection
            .filter()
            .catIdEqualTo(catId)
            .recordedAtGreaterThan(startDate)
            .recordedAtLessThan(endDate)
            .findAll()
        : await collection
            .filter()
            .recordedAtGreaterThan(startDate)
            .recordedAtLessThan(endDate)
            .findAll();

    return logs
        .map((log) => '${log.recordedAt.year}-${log.recordedAt.month.toString().padLeft(2, '0')}-${log.recordedAt.day.toString().padLeft(2, '0')}')
        .toSet();
  }
}

/// GetCalendarEvents UseCase 的 Riverpod Provider
@riverpod
GetCalendarEvents getCalendarEvents(GetCalendarEventsRef ref) {
  return GetCalendarEvents(IsarDatabase.instance);
}
