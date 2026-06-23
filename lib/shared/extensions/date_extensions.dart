/// 日期扩展
/// 提供 DateTime 的常用扩展方法，简化日期格式化和判断操作。
extension DateExtensions on DateTime {
  /// 格式化友好日期字符串
  /// 如果是今天，返回 "今天 HH:mm"
  /// 如果是昨天，返回 "昨天 HH:mm"
  /// 否则返回 "yyyy-MM-dd HH:mm"
  String formatFriendly() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final current = DateTime(year, month, day);

    final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    if (current == today) {
      return '今天 $timeStr';
    } else if (current == yesterday) {
      return '昨天 $timeStr';
    } else {
      return '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} $timeStr';
    }
  }

  /// 判断是否为今天
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 判断是否为昨天
  bool isYesterday() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// 计算与另一个日期之间的天数差
  /// 返回当前日期减去 [other] 的天数（可为负数）
  int daysBetween(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.difference(otherDate).inDays;
  }

  /// 转换为 yyyy-MM-dd 格式的字符串
  String toYmd() {
    return '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
