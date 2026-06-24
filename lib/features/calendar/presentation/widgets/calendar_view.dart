import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/event_list.dart';
import '../../log/domain/enums/log_type.dart';

/// 日历视图组件
///
/// 展示按月排列的日历网格，标记有事件记录的日期。
/// 支持点击日期查看当日事件列表。
///
/// 使用示例：
/// ```dart
/// CalendarView(
///   events: eventList,
///   eventDates: eventDateSet,
///   onDaySelected: (date) => showDayEvents(date),
/// )
/// ```
class CalendarView extends StatefulWidget {
  /// 当月的事件列表
  final List<dynamic> events;

  /// 有事件的日期集合（yyyy-MM-dd 格式）
  final Set<String> eventDates;

  /// 当前显示的年月
  final DateTime currentMonth;

  /// 日期选择回调
  final ValueChanged<DateTime> onDaySelected;

  /// 可选的猫咪 ID 筛选
  final int? catId;

  const CalendarView({
    super.key,
    this.events = const [],
    this.eventDates = const {},
    required this.currentMonth,
    required this.onDaySelected,
    this.catId,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentYearMonth;

  @override
  void initState() {
    super.initState();
    _currentYearMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month);
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth.month != widget.currentMonth.month ||
        oldWidget.currentMonth.year != widget.currentMonth.year) {
      setState(() {
        _currentYearMonth = DateTime(
          widget.currentMonth.year,
          widget.currentMonth.month,
        );
      });
    }
  }

  /// 切换到上个月
  void _previousMonth() {
    setState(() {
      _currentYearMonth = DateTime(
        _currentYearMonth.year,
        _currentYearMonth.month - 1,
      );
    });
  }

  /// 切换到下个月
  void _nextMonth() {
    setState(() {
      _currentYearMonth = DateTime(
        _currentYearMonth.year,
        _currentYearMonth.month + 1,
      );
    });
  }

  /// 跳转到今天
  void _jumpToToday() {
    setState(() {
      _currentYearMonth = DateTime.now();
    });
    widget.onDaySelected(DateTime.now());
  }

  /// 判断某天是否有事件
  bool _hasEvent(int year, int month, int day) {
    final dateStr = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return widget.eventDates.contains(dateStr);
  }

  /// 获取某月的天数
  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 获取某月第一天是周几（0=周日, 1=周一...）
  int _firstDayOfWeek(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  /// 获取当月所有日期格子（含前后月填充）
  List<_DayCell> _buildDayCells() {
    final cells = <_DayCell>[];
    final daysInMonth = _daysInMonth(_currentYearMonth.year, _currentYearMonth.month);
    final firstDay = _firstDayOfWeek(_currentYearMonth.year, _currentYearMonth.month);

    // 前月填充
    final prevMonth = _currentYearMonth.month == 1
        ? 12
        : _currentYearMonth.month - 1;
    final prevYear = _currentYearMonth.month == 1
        ? _currentYearMonth.year - 1
        : _currentYearMonth.year;
    final daysInPrevMonth = _daysInMonth(prevYear, prevMonth);

    for (int i = firstDay - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      cells.add(_DayCell(day, prevYear, prevMonth, isCurrentMonth: false));
    }

    // 当月
    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(_DayCell(day, _currentYearMonth.year, _currentYearMonth.month, isCurrentMonth: true));
    }

    // 后月填充（补齐最后一行）
    final remaining = 42 - cells.length; // 6 行 x 7 列 = 42
    final nextMonth = _currentYearMonth.month == 12
        ? 1
        : _currentYearMonth.month + 1;
    final nextYear = _currentYearMonth.month == 12
        ? _currentYearMonth.year + 1
        : _currentYearMonth.year;

    for (int day = 1; day <= remaining; day++) {
      cells.add(_DayCell(day, nextYear, nextMonth, isCurrentMonth: false));
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ====== 月份导航栏 ======
        _buildMonthHeader(),
        const SizedBox(height: 8),
        // ====== 星期标题 ======
        _buildWeekdayHeaders(),
        const SizedBox(height: 4),
        // ====== 日历网格 ======
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 42, // 6 行 x 7 列
            itemBuilder: (context, index) {
              final cell = _buildDayCells()[index];
              return _buildDayCell(cell);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 构建月份导航栏
  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上个月
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: _previousMonth,
            color: AppColors.lightTextSecondary,
            tooltip: '上个月',
          ),
          // 当前月份 + 跳转今天
          TextButton.icon(
            onPressed: _jumpToToday,
            icon: const Icon(Icons.today_rounded, size: 18),
            label: Text(
              DateFormat('yyyy 年 M 月').format(_currentYearMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightTextPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
          // 下个月
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            onPressed: _nextMonth,
            color: AppColors.lightTextSecondary,
            tooltip: '下个月',
          ),
        ],
      ),
    );
  }

  /// 构建星期标题行
  Widget _buildWeekdayHeaders() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ['一', '二', '三', '四', '五', '六', '日'].map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextHint,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建单个日期格子
  Widget _buildDayCell(_DayCell cell) {
    final isToday = cell.isCurrentMonth &&
        cell.year == DateTime.now().year &&
        cell.month == DateTime.now().month &&
        cell.day == DateTime.now().day;

    final hasEvent = cell.isCurrentMonth && _hasEvent(cell.year, cell.month, cell.day);
    final isWeekend = cell.dayOfWeek == 0 || cell.dayOfWeek == 6;

    return GestureDetector(
      onTap: cell.isCurrentMonth
          ? () => widget.onDaySelected(DateTime(cell.year, cell.month, cell.day))
          : null,
      child: Container(
        decoration: isToday
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 日期数字
            Text(
              '${cell.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: cell.isCurrentMonth
                    ? (isToday ? AppColors.primary : (isWeekend ? AppColors.error : AppColors.lightTextPrimary))
                    : AppColors.lightTextHint.withOpacity(0.4),
              ),
            ),
            // 事件指示点
            if (hasEvent) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 日期格子数据
class _DayCell {
  final int day;
  final int year;
  final int month;
  final bool isCurrentMonth;
  final int dayOfWeek; // 0=周日, 1=周一...

  _DayCell(this.day, this.year, this.month, {required this.isCurrentMonth})
      : dayOfWeek = DateTime(year, month, day).weekday % 7;
}
