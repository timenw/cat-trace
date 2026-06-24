// 日期工具类
///
/// 提供猫迹 App 中常用的日期处理方法，包括：
///   - 友好时间显示（如"3天前"、"2周前"）
///   - 日期范围格式化
///   - 月份/星期名称获取
///   - 日期比较（是否为今天、昨天）
///   - 天数差计算
///
/// 本文件中的 CatTraceDateUtils 与 intl 包的 DateFormat 配合使用，
/// 可根据需要切换为纯中文或国际化输出。
import 'package:intl/intl.dart';

/// 猫迹日期工具类
///
/// 所有方法均为静态方法，无需实例化。
class CatTraceDateUtils {
  CatTraceDateUtils._();

  // ==================== 友好格式 ====================

  /// 将日期格式化为友好的人类可读文本
  ///
  /// 规则：
  ///   - 今天 → "今天 HH:mm"
  ///   - 昨天 → "昨天 HH:mm"
  ///   - 7天内 → "N天前"
  ///   - 30天内 → "N周前"
  ///   - 365天内 → "N个月前"
  ///   - 超过365天 → "N年前"
  ///
  /// 示例：
  ///   - `formatFriendly(DateTime.now())` → "今天 14:30"
  ///   - `formatFriendly(DateTime.now().subtract(Duration(days: 3)))` → "3天前"
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    // 只比较日期部分是否相同
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(targetDate).inDays;

    final timeStr = DateFormat('HH:mm').format(date);

    if (diff == 0) {
      return '今天 $timeStr';
    } else if (diff == 1) {
      return '昨天 $timeStr';
    } else if (diff < 7) {
      return '${diff}天前';
    } else if (diff < 30) {
      final weeks = (diff / 7).floor();
      return '${weeks}周前';
    } else if (diff < 365) {
      final months = (diff / 30).floor();
      return '${months}个月前';
    } else {
      final years = (diff / 365).floor();
      return '${years}年前';
    }
  }

  /// 格式化日期范围
  ///
  /// 如果起止日期为同一天，只返回一个日期；
  /// 否则返回 "开始日期 ~ 结束日期" 的格式。
  ///
  /// 示例：
  ///   - 同一天 → "2024-06-15"
  ///   - 不同天 → "2024-06-01 ~ 2024-06-15"
  static String formatDateRange(DateTime start, DateTime end) {
    final fmt = DateFormat('yyyy-MM-dd');
    if (_isSameDay(start, end)) {
      return fmt.format(start);
    }
    return '${fmt.format(start)} ~ ${fmt.format(end)}';
  }

  // ==================== 月份 / 星期名称 ====================

  /// 获取中文月份名称
  ///
  /// [month] 取值范围 1-12。
  ///
  /// 示例：
  ///   - `getMonthName(1)` → "一月"
  ///   - `getMonthName(12)` → "十二月"
  static String getMonthName(int month) {
    const months = [
      '', // 索引0占位
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月',
    ];
    if (month < 1 || month > 12) return '';
    return months[month];
  }

  /// 获取中文星期名称
  ///
  /// [weekday] 取值范围 1-7（1=周一, 7=周日），与 DateTime.weekday 一致。
  ///
  /// 示例：
  ///   - `getWeekdayName(1)` → "周一"
  ///   - `getWeekdayName(7)` → "周日"
  static String getWeekdayName(int weekday) {
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    if (weekday < 1 || weekday > 7) return '';
    return weekdays[weekday];
  }

  // ==================== 日期比较 ====================

  /// 判断指定日期是否为今天
  ///
  /// 仅比较年/月/日，忽略时间部分。
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  /// 判断指定日期是否为昨天
  ///
  /// 仅比较年/月/日，忽略时间部分。
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }

  // ==================== 天数计算 ====================

  /// 计算两个日期之间的天数差
  ///
  /// 返回 [end] 减去 [start] 的天数（可能为负数）。
  /// 仅比较日期部分，忽略时间部分（时分秒不影响结果）。
  ///
  /// 示例：
  ///   - `daysBetween(2024-01-01, 2024-01-10)` → 9
  ///   - `daysBetween(2024-01-10, 2024-01-01)` → -9
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// 计算从指定日期到今天的天数
  ///
  /// 如果 [from] 是过去日期，返回正数；如果是未来日期，返回负数。
  ///
  /// 示例：
  ///   - 3天前 → 返回 3
  ///   - 明天 → 返回 -1
  static int daysFrom(DateTime from) {
    return daysBetween(from, DateTime.now());
  }

  // ==================== 辅助方法 ====================

  /// 判断两个日期是否为同一天（忽略时间部分）
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 格式化为 "yyyy-MM-dd HH:mm" 格式
  ///
  /// 适用于日志记录、备份文件命名等场景。
  static String formatWithTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// 格式化为 "yyyy年MM月dd日" 中文格式
  ///
  /// 适用于面向中文用户的展示场景。
  static String formatChinese(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 格式化为 "yyyyMMdd_HHmmss" 紧凑格式
  ///
  /// 适用于文件命名、时间戳等不需要空格和特殊字符的场景。
  static String formatCompact(DateTime date) {
    return DateFormat('yyyyMMdd_HHmmss').format(date);
  }
}
