import '../../domain/enums/feed_type.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/enums/log_type.dart';

/// 投喂量枚举
enum FeedAmount {
  small,   // 少量
  medium,  // 适量
  large,   // 大量
}

/// 日志实体类
///
/// Domain 层的日志实体，与数据库 Schema（LogSchema）对齐，
/// 用于记录与猫咪相关的各类活动，包括投喂、健康观察和观察笔记。
/// 字段与 LogSchema 保持一一对应，用于业务逻辑处理和 UI 交互。
class LogEntity {
  /// 唯一标识符
  final int id;

  /// 关联的猫咪 ID
  final int catId;

  /// 日志类型（投喂 / 健康观察 / 观察笔记）
  final LogType type;

  /// 记录时间（用户实际观察/投喂的时间）
  final DateTime recordedAt;

  /// 记录创建时间（系统写入时间）
  final DateTime createdAt;

  // ====== 投喂相关字段 ======

  /// 食物类型（干粮、湿粮、零食、生骨肉、羊奶、其他）
  final FeedType? feedType;

  /// 投喂量（少量、适量、大量）
  final FeedAmount? feedAmount;

  // ====== 健康观察相关字段 ======

  /// 整体健康状态（非常好、良好、一般、较差、危急）
  final HealthStatus? healthStatus;

  /// 精神状态评分（1-5 分，5 分为最佳）
  final int? spiritScore;

  /// 毛发状态评分（1-5 分，5 分为最佳）
  final int? furScore;

  /// 是否有伤病
  final bool? hasInjury;

  /// 伤病描述（如 "左前腿轻微跛行"）
  final String? injuryDescription;

  /// 体重估算（单位：kg）
  final double? weightEstimate;

  // ====== 通用字段 ======

  /// 备注（用户自由填写的补充信息）
  final String? notes;

  /// 位置描述（模糊位置，如 "食堂后门"）
  final String? locationHint;

  /// 纬度（可选，仅在开启定位功能时记录）
  final double? latitude;

  /// 经度（可选，仅在开启定位功能时记录）
  final double? longitude;

  const LogEntity({
    this.id = 0,
    this.catId = 0,
    this.type = LogType.note,
    required this.recordedAt,
    required this.createdAt,
    this.feedType,
    this.feedAmount,
    this.healthStatus,
    this.spiritScore,
    this.furScore,
    this.hasInjury,
    this.injuryDescription,
    this.weightEstimate,
    this.notes,
    this.locationHint,
    this.latitude,
    this.longitude,
  });

  /// 从 JSON Map 创建 LogEntity 实例
  factory LogEntity.fromJson(Map<String, dynamic> json) {
    return LogEntity(
      id: json['id'] as int? ?? 0,
      catId: json['catId'] as int? ?? 0,
      type: LogType.fromString(json['type'] as String? ?? 'note'),
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      feedType: json['feedType'] != null
          ? FeedType.fromString(json['feedType'] as String)
          : null,
      feedAmount: _parseFeedAmount(json['feedAmount'] as String?),
      healthStatus: json['healthStatus'] != null
          ? HealthStatus.fromString(json['healthStatus'] as String)
          : null,
      spiritScore: json['spiritScore'] as int?,
      furScore: json['furScore'] as int?,
      hasInjury: json['hasInjury'] as bool?,
      injuryDescription: json['injuryDescription'] as String?,
      weightEstimate: (json['weightEstimate'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      locationHint: json['locationHint'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// 将 LogEntity 实例转换为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catId': catId,
      'type': type.name,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'feedType': feedType?.name,
      'feedAmount': feedAmount?.name,
      'healthStatus': healthStatus?.name,
      'spiritScore': spiritScore,
      'furScore': furScore,
      'hasInjury': hasInjury,
      'injuryDescription': injuryDescription,
      'weightEstimate': weightEstimate,
      'notes': notes,
      'locationHint': locationHint,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// 创建 LogEntity 的副本，可选择性地更新部分字段
  LogEntity copyWith({
    int? id,
    int? catId,
    LogType? type,
    DateTime? recordedAt,
    DateTime? createdAt,
    FeedType? feedType,
    FeedAmount? feedAmount,
    HealthStatus? healthStatus,
    int? spiritScore,
    int? furScore,
    bool? hasInjury,
    String? injuryDescription,
    double? weightEstimate,
    String? notes,
    String? locationHint,
    double? latitude,
    double? longitude,
  }) {
    return LogEntity(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      type: type ?? this.type,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      feedType: feedType ?? this.feedType,
      feedAmount: feedAmount ?? this.feedAmount,
      healthStatus: healthStatus ?? this.healthStatus,
      spiritScore: spiritScore ?? this.spiritScore,
      furScore: furScore ?? this.furScore,
      hasInjury: hasInjury ?? this.hasInjury,
      injuryDescription: injuryDescription ?? this.injuryDescription,
      weightEstimate: weightEstimate ?? this.weightEstimate,
      notes: notes ?? this.notes,
      locationHint: locationHint ?? this.locationHint,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// 是否为投喂类型日志
  bool get isFeedLog => type == LogType.feed;

  /// 是否为健康观察类型日志
  bool get isHealthLog => type == LogType.health;

  /// 是否为观察笔记类型日志
  bool get isNoteLog => type == LogType.note;

  /// 获取健康评分的平均值（精神状态和毛发状态的平均）
  double? get averageHealthScore {
    if (spiritScore == null && furScore == null) return null;
    int count = 0;
    int total = 0;
    if (spiritScore != null) {
      count++;
      total += spiritScore!;
    }
    if (furScore != null) {
      count++;
      total += furScore!;
    }
    return total / count;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LogEntity(id: $id, catId: $catId, type: ${type.name}, recordedAt: $recordedAt)';
}

/// 解析投喂量枚举
FeedAmount? _parseFeedAmount(String? value) {
  if (value == null) return null;
  switch (value) {
    case 'small':
      return FeedAmount.small;
    case 'medium':
      return FeedAmount.medium;
    case 'large':
      return FeedAmount.large;
    default:
      return null;
  }
}
