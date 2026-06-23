import 'package:flutter/material.dart';

/// 猫迹 App 主题扩展
/// 定义应用专属的颜色、样式和设计令牌
class CatTheme {
  CatTheme._();

  // ==================== 品牌色 ====================

  /// 主色调 - 温暖的橙色（像猫咪的毛色）
  static const Color primaryColor = Color(0xFFFF8C42);

  /// 次要色调 - 柔和的粉色
  static const Color secondaryColor = Color(0xFFFF6B9D);

  /// 强调色 - 清新的绿色
  static const Color accentColor = Color(0xFF4CAF50);

  // ==================== 稀有度颜色 ====================

  /// 常见 - 灰色
  static const Color rarityCommon = Color(0xFF9E9E9E);

  /// 稀有 - 蓝色
  static const Color rarityRare = Color(0xFF42A5F5);

  /// 史诗 - 紫色
  static const Color rarityEpic = Color(0xFFAB47BC);

  /// 传说 - 橙色
  static const Color rarityLegendary = Color(0xFFFFA726);

  /// 神话 - 红色
  static const Color rarityMythic = Color(0xFFEF5350);

  // ==================== 语义色 ====================

  /// 成功
  static const Color successColor = Color(0xFF4CAF50);

  /// 警告
  static const Color warningColor = Color(0xFFFFA726);

  /// 错误
  static const Color errorColor = Color(0xFFEF5350);

  /// 信息
  static const Color infoColor = Color(0xFF42A5F5);

  // ==================== 浅色主题 ====================

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: const Color(0xFFFFFBF7),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      useMaterial3: true,

      // AppBar 主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // 卡片主题
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // 按钮主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
      ),

      // 对话框主题
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: colorScheme.surface,
      ),

      // 底部弹窗主题
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // 文本主题
      textTheme: _buildTextTheme(base.textTheme, colorScheme),

      // 图标主题
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withOpacity(0.7),
        size: 24,
      ),

      // Chip 主题
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        selectedColor: colorScheme.primary.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        labelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.15),
        circularTrackColor: colorScheme.primary.withOpacity(0.15),
      ),

      // 浮动按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }

  // ==================== 深色主题 ====================

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: const Color(0xFF1A1A2E),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      useMaterial3: true,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
      ),

      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: colorScheme.surface,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      textTheme: _buildTextTheme(base.textTheme, colorScheme),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        selectedColor: colorScheme.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        labelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.2),
        circularTrackColor: colorScheme.primary.withOpacity(0.2),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }

  // ==================== 文本主题 ====================

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withOpacity(0.8),
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: colorScheme.onSurface.withOpacity(0.85),
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        color: colorScheme.onSurface.withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withOpacity(0.8),
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  // ==================== 渐变 ====================

  /// 主渐变（橙色到粉色）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 背景渐变（浅色）
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFBF7), Color(0xFFFFF3E0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 背景渐变（深色）
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== 阴影 ====================

  /// 卡片阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// 浮动阴影
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== 圆角 ====================

  /// 小圆角
  static const double radiusSmall = 8;

  /// 中等圆角
  static const double radiusMedium = 12;

  /// 大圆角
  static const double radiusLarge = 16;

  /// 超大圆角
  static const double radiusXLarge = 24;

  /// 圆形
  static const double radiusCircle = 999;

  // ==================== 间距 ====================

  /// 超小间距
  static const double spacingXS = 4;

  /// 小间距
  static const double spacingS = 8;

  /// 中等间距
  static const double spacingM = 16;

  /// 大间距
  static const double spacingL = 24;

  /// 超大间距
  static const double spacingXL = 32;

  // ==================== 图标大小 ====================

  /// 小图标
  static const double iconSmall = 16;

  /// 中等图标
  static const double iconMedium = 24;

  /// 大图标
  static const double iconLarge = 32;

  /// 超大图标
  static const double iconXLarge = 48;
}
