/// 字符串扩展
/// 提供 String 的常用扩展方法，简化和增强字符串操作。
extension StringExtensions on String {
  /// 首字母大写，其余小写
  /// 如果字符串为空则原样返回
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// 截断字符串到指定长度，超出部分用 [suffix] 替代
  /// [maxLength] 最大长度（包含后缀）
  /// [suffix] 后缀字符串，默认为 "..."
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

/// 可空字符串扩展
/// 提供针对 String? 的便捷判断和转换方法
extension NullableStringExtensions on String? {
  /// 判断字符串是否为 null 或空
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  /// 将字符串安全地转换为 double
  /// 如果字符串为 null、空或无法解析，返回 null
  double? toDoubleOrNull() {
    if (isNullOrEmpty()) return null;
    return double.tryParse(this!);
  }
}
