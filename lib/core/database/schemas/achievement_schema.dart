import 'package:isar/isar.dart';

part 'achievement_schema.g.dart';

/// 成就数据模型
@collection
class AchievementSchema {
  Id id = Isar.autoIncrement;

  /// 成就唯一标识
  @Index(type: IndexType.value, unique: true)
  String achievementId = '';

  /// 成就名称
  String name = '';

  /// 成就描述
  String description = '';

  /// 成就图标（emoji）
  String icon = '';

  /// 稀有度: common, uncommon, rare, epic, legendary
  @Index()
  @enumerated
  AchievementRarity rarity = AchievementRarity.common;

  /// 是否已解锁
  @Index()
  bool isUnlocked = false;

  /// 解锁时间
  DateTime? unlockedAt;

  /// 进度值
  int progress = 0;

  /// 目标值
  int target = 1;

  /// 分类: collection, log, tnr, special
  @Index()
  @enumerated
  AchievementCategory category = AchievementCategory.collection;

  /// 排序
  int sortOrder = 0;
}

/// 成就稀有度
enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// 成就分类
enum AchievementCategory {
  collection,  // 收集类
  log,         // 记录类
  tnr,         // TNR 类
  special,     // 特殊类
}
