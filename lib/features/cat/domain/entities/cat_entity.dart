import '../../domain/enums/cat_breed.dart';
import '../../domain/enums/cat_color.dart';
import '../../domain/enums/rarity.dart';
import '../../domain/enums/tnr_status.dart';

/// 猫咪性别枚举
enum CatGender {
  unknown,
  male,
  female,
}

/// 猫咪实体类
///
/// Domain 层的猫咪实体，与数据库 Schema（CatSchema）对齐，
/// 但不依赖任何基础设施层的实现。
/// 字段与 CatSchema 保持一一对应，用于业务逻辑处理和 UI 交互。
class CatEntity {
  /// 唯一标识符
  final int id;

  /// 猫咪昵称
  final String? nickname;

  /// 品种（如：英短、布偶猫等）
  final CatBreed breed;

  /// 毛色（如：橘猫、三花、奶牛等）
  final CatColor color;

  /// 性别（未知、公猫、母猫）
  final CatGender gender;

  /// 估算年龄（单位：月）
  final int? estimatedAgeMonths;

  /// 特征标签列表（如 ["亲人", "大尾巴", "异瞳"]）
  final List<String> tags;

  /// TNR 状态（未绝育 / 已耳缺 / 已绝育）
  final TnrStatus tnrStatus;

  /// 稀有度（普通、稀有、罕见、史诗、传说）
  final Rarity rarity;

  /// 发现位置描述（模糊位置，如 "东区花坛旁"）
  final String? locationHint;

  /// 纬度（可选，仅在开启定位功能时记录）
  final double? latitude;

  /// 经度（可选，仅在开启定位功能时记录）
  final double? longitude;

  /// 首次发现时间
  final DateTime firstSeenAt;

  /// 最近一次观察时间
  final DateTime lastSeenAt;

  /// 记录创建时间
  final DateTime createdAt;

  /// 记录更新时间
  final DateTime updatedAt;

  /// 是否已软删除
  final bool isDeleted;

  /// 用户备注
  final String? notes;

  /// 投喂提醒时间（小时，24 小时制，如 8 表示 08:00）
  final int? feedReminderHour;

  /// 投喂提醒时间（分钟，如 30 表示 XX:30）
  final int? feedReminderMinute;

  /// 健康观察提醒时间（小时，24 小时制）
  final int? healthReminderHour;

  /// 健康观察提醒时间（分钟）
  final int? healthReminderMinute;

  /// 提醒功能是否开启
  final bool reminderEnabled;

  const CatEntity({
    this.id = 0,
    this.nickname,
    this.breed = CatBreed.unknown,
    this.color = CatColor.unknown,
    this.gender = CatGender.unknown,
    this.estimatedAgeMonths,
    this.tags = const [],
    this.tnrStatus = TnrStatus.none,
    this.rarity = Rarity.common,
    this.locationHint,
    this.latitude,
    this.longitude,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.notes,
    this.feedReminderHour,
    this.feedReminderMinute,
    this.healthReminderHour,
    this.healthReminderMinute,
    this.reminderEnabled = false,
  });

  /// 从 JSON Map 创建 CatEntity 实例
  factory CatEntity.fromJson(Map<String, dynamic> json) {
    return CatEntity(
      id: json['id'] as int? ?? 0,
      nickname: json['nickname'] as String?,
      breed: CatBreed.fromString(json['breed'] as String? ?? 'unknown'),
      color: CatColor.fromString(json['color'] as String? ?? 'unknown'),
      gender: _parseCatGender(json['gender'] as String?),
      estimatedAgeMonths: json['estimatedAgeMonths'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tnrStatus: TnrStatus.fromString(json['tnrStatus'] as String? ?? 'none'),
      rarity: Rarity.fromString(json['rarity'] as String? ?? 'common'),
      locationHint: json['locationHint'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      firstSeenAt: json['firstSeenAt'] != null
          ? DateTime.parse(json['firstSeenAt'] as String)
          : DateTime.now(),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      feedReminderHour: json['feedReminderHour'] as int?,
      feedReminderMinute: json['feedReminderMinute'] as int?,
      healthReminderHour: json['healthReminderHour'] as int?,
      healthReminderMinute: json['healthReminderMinute'] as int?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    );
  }

  /// 将 CatEntity 实例转换为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'breed': breed.name,
      'color': color.name,
      'gender': gender.name,
      'estimatedAgeMonths': estimatedAgeMonths,
      'tags': tags,
      'tnrStatus': tnrStatus.name,
      'rarity': rarity.name,
      'locationHint': locationHint,
      'latitude': latitude,
      'longitude': longitude,
      'firstSeenAt': firstSeenAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'notes': notes,
      'feedReminderHour': feedReminderHour,
      'feedReminderMinute': feedReminderMinute,
      'healthReminderHour': healthReminderHour,
      'healthReminderMinute': healthReminderMinute,
      'reminderEnabled': reminderEnabled,
    };
  }

  /// 创建 CatEntity 的副本，可选择性地更新部分字段
  CatEntity copyWith({
    int? id,
    String? nickname,
    CatBreed? breed,
    CatColor? color,
    CatGender? gender,
    int? estimatedAgeMonths,
    List<String>? tags,
    TnrStatus? tnrStatus,
    Rarity? rarity,
    String? locationHint,
    double? latitude,
    double? longitude,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? notes,
    int? feedReminderHour,
    int? feedReminderMinute,
    int? healthReminderHour,
    int? healthReminderMinute,
    bool? reminderEnabled,
  }) {
    return CatEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      gender: gender ?? this.gender,
      estimatedAgeMonths: estimatedAgeMonths ?? this.estimatedAgeMonths,
      tags: tags ?? this.tags,
      tnrStatus: tnrStatus ?? this.tnrStatus,
      rarity: rarity ?? this.rarity,
      locationHint: locationHint ?? this.locationHint,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      notes: notes ?? this.notes,
      feedReminderHour: feedReminderHour ?? this.feedReminderHour,
      feedReminderMinute: feedReminderMinute ?? this.feedReminderMinute,
      healthReminderHour: healthReminderHour ?? this.healthReminderHour,
      healthReminderMinute: healthReminderMinute ?? this.healthReminderMinute,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  /// 获取显示名称（优先使用昵称，否则返回品种名）
  String get displayName => nickname ?? breed.displayName;

  /// 获取估算年龄的友好显示文本
  String get ageDisplayText {
    if (estimatedAgeMonths == null) return '年龄未知';
    final months = estimatedAgeMonths!;
    if (months < 1) return '新生';
    if (months < 12) return '$months 个月';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) return '$years 岁';
    return '$years 岁 $remainingMonths 个月';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CatEntity(id: $id, nickname: $nickname, breed: ${breed.name}, color: ${color.name})';
}

/// 解析猫咪性别枚举
CatGender _parseCatGender(String? value) {
  switch (value) {
    case 'male':
      return CatGender.male;
    case 'female':
      return CatGender.female;
    default:
      return CatGender.unknown;
  }
}
