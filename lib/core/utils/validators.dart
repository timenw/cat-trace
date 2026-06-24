/// 验证工具类
///
/// 提供猫迹 App 中常用的表单验证方法，包括：
///   - 猫咪昵称验证
///   - 备注文本验证
///   - 体重输入验证
///   - 估算年龄验证
///
/// 所有方法均返回 `String?`：
///   - 返回 `null` 表示验证通过
///   - 返回错误提示字符串表示验证不通过
///
/// 这些方法可直接用于 Flutter Form 的 `validator` 参数。
///
/// 使用示例：
/// ```dart
/// TextFormField(
///   validator: Validators.validateNickname,
/// )
/// ```

/// 猫迹验证工具类
///
/// 所有方法均为静态方法，无需实例化。
class Validators {
  Validators._();

  // ==================== 昵称验证 ====================

  /// 验证猫咪昵称
  ///
  /// 规则：
  ///   - 不能为空或纯空白字符
  ///   - 长度不超过 20 个字符（中英文均算一个字符）
  ///   - 不能包含特殊字符（仅允许中英文、数字、空格和常见符号）
  ///
  /// 示例：
  ///   - `validateNickname(null)` → "请输入昵称"
  ///   - `validateNickname("")` → "请输入昵称"
  ///   - `validateNickname("   ")` → "请输入昵称"
  ///   - `validateNickname("橘猫小咪")` → null（验证通过）
  ///   - `validateNickname("a" * 21)` → "昵称不能超过20个字符"
  static String? validateNickname(String? value) {
    // 空值检查
    if (value == null || value.trim().isEmpty) {
      return '请输入昵称';
    }

    // 长度检查
    if (value.trim().length > 20) {
      return '昵称不能超过20个字符';
    }

    // 特殊字符检查（仅允许中英文、数字、空格和部分符号）
    final allowedPattern = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9\s\-_·]+$');
    if (!allowedPattern.hasMatch(value.trim())) {
      return '昵称只能包含中英文、数字和空格';
    }

    return null; // 验证通过
  }

  // ==================== 备注验证 ====================

  /// 验证备注文本
  ///
  /// 规则：
  ///   - 可以为空（非必填字段）
  ///   - 如果填写，长度不能超过 500 个字符
  ///
  /// 示例：
  ///   - `validateNotes(null)` → null（验证通过）
  ///   - `validateNotes("")` → null（验证通过）
  ///   - `validateNotes("很亲人的一只猫")` → null（验证通过）
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 非必填字段，为空时通过验证
    }
    if (value.length > 500) {
      return '备注不能超过500个字符';
    }
    return null;
  }

  // ==================== 体重验证 ====================

  /// 验证体重输入
  ///
  /// 规则：
  ///   - 可以为空（非必填字段）
  ///   - 如果填写，必须是有效的数字
  ///   - 数值范围：0 < weight ≤ 20（kg）
  ///   - 最多支持1位小数
  ///
  /// 示例：
  ///   - `validateWeight(null)` → null（验证通过）
  ///   - `validateWeight("")` → null（验证通过）
  ///   - `validateWeight("4.5")` → null（验证通过）
  ///   - `validateWeight("abc")` → "请输入有效数字"
  ///   - `validateWeight("25")` → "体重范围 0-20kg"
  ///   - `validateWeight("-1")` → "体重范围 0-20kg"
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 非必填
    }

    // 数字格式检查
    final weight = double.tryParse(value);
    if (weight == null) {
      return '请输入有效数字';
    }

    // 范围检查
    if (weight <= 0 || weight > 20) {
      return '体重范围 0-20kg';
    }

    return null;
  }

  // ==================== 年龄验证 ====================

  /// 验证估算年龄输入
  ///
  /// 规则：
  ///   - 可以为空（非必填字段）
  ///   - 如果填写，必须是有效的正整数
  ///   - 数值范围：1 ≤ age ≤ 240（月），即 0-20 岁
  ///
  /// 示例：
  ///   - `validateAge(null)` → null（验证通过）
  ///   - `validateAge("6")` → null（验证通过，6个月）
  ///   - `validateAge("abc")` → "请输入有效数字"
  ///   - `validateAge("300")` → "年龄范围 1-240 个月"
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 非必填
    }

    // 整数格式检查
    final age = int.tryParse(value);
    if (age == null) {
      return '请输入有效数字';
    }

    // 范围检查：1-240个月（20年）
    if (age < 1 || age > 240) {
      return '年龄范围 1-240 个月';
    }

    return null;
  }

  // ==================== 通用辅助验证 ====================

  /// 验证非空字符串
  ///
  /// 通用方法，适用于各种必填字段的验证。
  ///
  /// 参数：
  ///   - [value] 待验证的字符串
  ///   - [fieldName] 字段名称，用于错误提示（如"昵称"、"品种"）
  ///   - [maxLength] 最大长度限制（默认 100）
  static String? validateRequired(
    String? value, {
    required String fieldName,
    int maxLength = 100,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    if (value.trim().length > maxLength) {
      return '$fieldName不能超过$maxLength个字符';
    }
    return null;
  }

  /// 验证数值范围
  ///
  /// 通用方法，适用于需要在指定范围内的数值验证。
  ///
  /// 参数：
  ///   - [value] 待验证的字符串
  ///   - [fieldName] 字段名称，用于错误提示
  ///   - [min] 最小值（包含）
  ///   - [max] 最大值（包含）
  static String? validateRange(
    String? value, {
    required String fieldName,
    required num min,
    required num max,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final num? parsed = num.tryParse(value);
    if (parsed == null) {
      return '请输入有效数字';
    }
    if (parsed < min || parsed > max) {
      return '$fieldName范围 $min-$max';
    }
    return null;
  }
}
