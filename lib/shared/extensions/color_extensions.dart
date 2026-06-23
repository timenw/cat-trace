import 'dart:ui';

/// 颜色扩展
/// 提供 Color 的常用扩展方法，增强颜色操作能力。
extension ColorExtensions on Color {
  /// 将颜色转换为十六进制字符串（带 alpha 通道）
  /// 输出格式为 "#AARRGGBB"，字母大写
  String toHex({bool withAlpha = true}) {
    if (withAlpha) {
      return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    } else {
      // 仅 RGB 部分
      return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }
  }

  /// 加深颜色
  /// [amount] 加深程度，取值范围 0.0 ~ 1.0，值为 0 不变，值为 1 变为黑色
  /// 通过降低各通道的亮度实现
  Color darken(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount 必须在 0.0 到 1.0 之间');
    final factor = 1.0 - amount;
    return Color.fromRGBO(
      (red * factor).round(),
      (green * factor).round(),
      (blue * factor).round(),
      opacity,
    );
  }

  /// 减淡颜色（提亮）
  /// [amount] 提亮程度，取值范围 0.0 ~ 1.0，值为 0 不变，值为 1 变为白色
  /// 通过提高各通道的亮度实现
  Color lighten(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount 必须在 0.0 到 1.0 之间');
    final inv = 1.0 - amount;
    return Color.fromRGBO(
      ((red * inv) + (255 * amount)).round().clamp(0, 255),
      ((green * inv) + (255 * amount)).round().clamp(0, 255),
      ((blue * inv) + (255 * amount)).round().clamp(0, 255),
      opacity,
    );
  }
}
