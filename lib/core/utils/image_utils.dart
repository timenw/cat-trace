import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

/// 图片工具类
class ImageUtils {
  /// 添加隐形水印（在图片右下角添加半透明文字）
  static img.Image addWatermark(img.Image image, String text) {
    // 使用简单的文字水印
    final fontSize = (image.width / 30).clamp(12, 36).toInt();

    // 在右下角绘制半透明文字
    img.drawString(
      image,
      text,
      font: img.arial24,
      x: image.width - (text.length * fontSize ~/ 2) - 10,
      y: image.height - fontSize - 10,
      color: img.ColorRgba8(255, 255, 255, 80), // 半透明白色
    );

    return image;
  }

  /// 生成水印文本
  static String generateWatermarkText() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    return 'CT_$timestamp';
  }
}

/// 日期工具类
class DateUtils {
  /// 格式化日期为友好显示
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天 ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays == 1) {
      return '昨天 ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return '${(diff.inDays / 365).floor()}年前';
    }
  }

  /// 格式化日期范围
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return DateFormat('yyyy-MM-dd').format(start);
    }
    return '${DateFormat('yyyy-MM-dd').format(start)} ~ ${DateFormat('yyyy-MM-dd').format(end)}';
  }

  /// 获取月份名称
  static String getMonthName(int month) {
    const months = [
      '', '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return months[month];
  }

  /// 获取星期名称
  static String getWeekdayName(int weekday) {
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday];
  }
}

/// 验证工具类
class Validators {
  /// 验证昵称
  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入昵称';
    }
    if (value.trim().length > 20) {
      return '昵称不能超过20个字符';
    }
    return null;
  }

  /// 验证备注
  static String? validateNotes(String? value) {
    if (value != null && value.length > 500) {
      return '备注不能超过500个字符';
    }
    return null;
  }

  /// 验证体重
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final weight = double.tryParse(value);
    if (weight == null) return '请输入有效数字';
    if (weight <= 0 || weight > 20) return '体重范围 0-20kg';
    return null;
  }
}
