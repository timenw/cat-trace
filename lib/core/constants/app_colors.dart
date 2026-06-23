import 'package:flutter/material.dart';

/// App 颜色系统 — 治愈系温暖色调
class AppColors {
  AppColors._();

  // ====== 主色调 ======
  static const Color primary = Color(0xFFFF8A65);        // 温暖橙
  static const Color primaryLight = Color(0xFFFFAB91);   // 浅橙
  static const Color primaryDark = Color(0xFFE64A19);    // 深橙

  // ====== 辅助色 ======
  static const Color secondary = Color(0xFF81C784);      // 清新绿
  static const Color secondaryLight = Color(0xFFA5D6A7);
  static const Color secondaryDark = Color(0xFF66BB6A);

  static const Color accent = Color(0xFF64B5F6);         // 天空蓝
  static const Color accentLight = Color(0xFF90CAF9);
  static const Color accentDark = Color(0xFF42A5F5);

  // ====== 稀有度颜色 ======
  static const Color rarityCommon = Color(0xFF9E9E9E);    // 普通 - 灰
  static const Color rarityUncommon = Color(0xFF4CAF50); // 稀有 - 绿
  static const Color rarityRare = Color(0xFF2196F3);     // 罕见 - 蓝
  static const Color rarityEpic = Color(0xFF9C27B0);     // 史诗 - 紫
  static const Color rarityLegendary = Color(0xFFFF9800); // 传说 - 橙

  // ====== 状态颜色 ======
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // ====== 浅色模式 ======
  static const Color lightBackground = Color(0xFFFFFBF5);    // 暖白
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFF8F0);
  static const Color lightDivider = Color(0xFFF0E6DC);
  static const Color lightTextPrimary = Color(0xFF3E2723);
  static const Color lightTextSecondary = Color(0xFF6D4C41);
  static const Color lightTextHint = Color(0xFFBCAAA4);

  // ====== 深色模式 ======
  static const Color darkBackground = Color(0xFF1A1210);
  static const Color darkSurface = Color(0xFF2D201C);
  static const Color darkCard = Color(0xFF3D2E28);
  static const Color darkDivider = Color(0xFF4E342E);
  static const Color darkTextPrimary = Color(0xFFFBE9E7);
  static const Color darkTextSecondary = Color(0xFFD7CCC8);
  static const Color darkTextHint = Color(0xFF8D6E63);

  // ====== TNR 状态颜色 ======
  static const Color tnrNone = Color(0xFFE57373);      // 未做 - 红
  static const Color tnrEarTip = Color(0xFFFFB74D);    // 已耳缺 - 黄
  static const Color tnrNeutered = Color(0xFF81C784);  // 已绝育 - 绿

  // ====== 健康状态颜色 ======
  static const Color healthGood = Color(0xFF81C784);
  static const Color healthFair = Color(0xFFFFD54F);
  static const Color healthPoor = Color(0xFFE57373);
}
