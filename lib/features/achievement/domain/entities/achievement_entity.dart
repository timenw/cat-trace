/// 成就稀有度枚举
enum AchievementRarity {
  common,     // 普通
  uncommon,   // 稀有
  rare,       // 罕见
  epic,       // 史诗
  legendary,  // 传说
}

/// 成就分类枚举
enum AchievementCategory {
  collection,  // 收集类（如：收集到 X 只猫咪）
  log,         // 记录类（如：累计记录 X 条日志）
  tnr,         // TNR 类（如：帮助 X 只猫咪完成 TNR）
  special,     // 特殊类（如：特殊节日成就）
}

/// 成就实体类
///
/// Domain 层的成就实体，与数据库 Schema（AchievementSchema）对齐，
/// 用于记录用户在游戏中解锁的各类成就。
/// 字段与 AchievementSchema 保持一一对应，用于业务逻辑处理和 UI 交互。
class AchievementEntity {
  /// 唯一标识符
  final int id;

  /// 成就唯一标识（业务 ID，如 "first_cat", "feed_100_times"）
  final String achievementId;

  /// 成就名称（如 "初识喵星人"）
  final String name;

  /// 成就描述（如 "记录第一只猫咪"）
  final String description;

  /// 成就图标（emoji 字符，如 "🐱"）
  final String icon;

  /// 稀有度（普通、稀有、罕见、史诗、传说）
  final AchievementRarity rarity;

  /// 是否已解锁
  final bool isUnlocked;

  /// 解锁时间（未解锁时为 null）
  final DateTime? unlockedAt;

  /// 当前进度值
  final int progress;

  /// 目标值（达到此值时解锁）
  final int target;

  /// 成就分类（收集类、记录类、TNR 类、特殊类）
  final AchievementCategory category;

  /// 排序值（越小越靠前）
  final int sortOrder;

  const AchievementEntity({
    this.id = 0,
    this.achievementId = '',
    this.name = '',
    this.description = '',
    this.icon = '',
    this.rarity = AchievementRarity.common,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.target = 1,
    this.category = AchievementCategory.collection,
    this.sortOrder = 0,
  });

  /// 从 JSON Map 创建 AchievementEntity 实例
  factory AchievementEntity.fromJson(Map<String, dynamic> json) {
    return AchievementEntity(
      id: json['id'] as int? ?? 0,
      achievementId: json['achievementId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      rarity: _parseAchievementRarity(json['rarity'] as String?),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
      category: _parseAchievementCategory(json['category'] as String?),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// 将 AchievementEntity 实例转换为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'achievementId': achievementId,
      'name': name,
      'description': description,
      'icon': icon,
      'rarity': rarity.name,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
      'category': category.name,
      'sortOrder': sortOrder,
    };
  }

  /// 创建 AchievementEntity 的副本，可选择性地更新部分字段
  AchievementEntity copyWith({
    int? id,
    String? achievementId,
    String? name,
    String? description,
    String? icon,
    AchievementRarity? rarity,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? target,
    AchievementCategory? category,
    int? sortOrder,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// 计算进度百分比（0.0 ~ 1.0）
  double get progressPercent {
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// 获取进度百分比的友好显示文本（如 "75%"）
  String get progressPercentText => '${(progressPercent * 100).toInt()}%';

  /// 获取进度的友好显示文本（如 "3/10"）
  String get progressText => '$progress/$target';

  /// 是否即将解锁（进度 >= 80% 但未解锁）
  bool get isAlmostUnlocked => !isUnlocked && progressPercent >= 0.8;

  /// 获取稀有度的中文显示名称
  String get rarityDisplayName {
    switch (rarity) {
      case AchievementRarity.common:
        return '普通';
      case AchievementRarity.uncommon:
        return '稀有';
      case AchievementRarity.rare:
        return '罕见';
      case AchievementRarity.epic:
        return '史诗';
      case AchievementRarity.legendary:
        return '传说';
    }
  }

  /// 获取分类的中文显示名称
  String get categoryDisplayName {
    switch (category) {
      case AchievementCategory.collection:
        return '收集';
      case AchievementCategory.log:
        return '记录';
      case AchievementCategory.tnr:
        return 'TNR';
      case AchievementCategory.special:
        return '特殊';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AchievementEntity(id: $id, achievementId: $achievementId, name: $name, isUnlocked: $isUnlocked)';
}

/// 解析成就稀有度枚举
AchievementRarity _parseAchievementRarity(String? value) {
  switch (value) {
    case 'uncommon':
      return AchievementRarity.uncommon;
    case 'rare':
      return AchievementRarity.rare;
    case 'epic':
      return AchievementRarity.epic;
    case 'legendary':
      return AchievementRarity.legendary;
    default:
      return AchievementRarity.common;
  }
}

/// 解析成就分类枚举
AchievementCategory _parseAchievementCategory(String? value) {
  switch (value) {
    case 'log':
      return AchievementCategory.log;
    case 'tnr':
      return AchievementCategory.tnr;
    case 'special':
      return AchievementCategory.special;
    default:
      return AchievementCategory.collection;
  }
}
