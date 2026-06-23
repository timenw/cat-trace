import '../../domain/entities/log_entity.dart';
import '../../domain/enums/feed_type.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/enums/log_type.dart';

/// 日志 DTO（Data Transfer Object）
///
/// 用于在 Presentation 层和 Domain 层之间传递日志数据。
/// DTO 是对 [LogEntity] 的轻量级封装，不包含数据库 ID 和时间戳等持久化字段，
/// 专注于用户输入的数据传递。
///
/// 与 [LogEntity] 的区别：
/// - LogDto 不包含数据库 ID（id）、创建时间（createdAt）等自动生成的字段
/// - LogDto 的字段均为用户可编辑的，用于表单数据收集
/// - LogDto 支持 JSON 序列化，便于在不同层之间传递数据
///
/// 使用场景：
/// ```dart
/// // 用户填写表单 → LogDto
/// final dto = LogDto(
///   catId: 1,
///   type: LogType.feed,
///   feedType: FeedType.dryFood,
///   feedAmount: FeedAmount.medium,
/// );
///
/// // LogDto → LogEntity（保存到数据库）
/// final entity = dto.toEntity();
/// ```
class LogDto {
  /// 关联的猫咪 ID
  final int catId;

  /// 日志类型（投喂 / 健康观察 / 观察笔记）
  final LogType type;

  /// 记录时间（用户实际观察/投喂的时间）
  final DateTime recordedAt;

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

  /// 构造函数
  const LogDto({
    this.catId = 0,
    this.type = LogType.note,
    DateTime? recordedAt,
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
  }) : recordedAt = recordedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// 从 JSON Map 创建 LogDto 实例
  ///
  /// 用于从本地存储或网络请求中恢复 DTO 数据。
  factory LogDto.fromJson(Map<String, dynamic> json) {
    return LogDto(
      catId: json['catId'] as int? ?? 0,
      type: LogType.fromString(json['type'] as String? ?? 'note'),
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
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

  /// 将 LogDto 转换为 JSON Map
  ///
  /// 用于将 DTO 数据存储到本地或发送给后端服务。
  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'type': type.name,
      'recordedAt': recordedAt.toIso8601String(),
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

  /// 将 LogDto 转换为 LogEntity
  ///
  /// 用于用户提交表单后，将 DTO 数据保存到数据库。
  /// 注意：生成的 Entity ID 为 0（表示新增），
  /// 时间戳会设置为当前时间。
  LogEntity toEntity() {
    final now = DateTime.now();
    return LogEntity(
      id: 0, // 新增记录，ID 由数据库自动生成
      catId: catId,
      type: type,
      recordedAt: recordedAt.year == 0 ? now : recordedAt,
      createdAt: now,
      feedType: feedType,
      feedAmount: feedAmount,
      healthStatus: healthStatus,
      spiritScore: spiritScore,
      furScore: furScore,
      hasInjury: hasInjury,
      injuryDescription: injuryDescription,
      weightEstimate: weightEstimate,
      notes: notes,
      locationHint: locationHint,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// 创建 LogDto 的副本，可选择性地更新部分字段
  ///
  /// 用于表单中部分字段更新时保持其他字段不变。
  LogDto copyWith({
    int? catId,
    LogType? type,
    DateTime? recordedAt,
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
    return LogDto(
      catId: catId ?? this.catId,
      type: type ?? this.type,
      recordedAt: recordedAt ?? this.recordedAt,
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

  @override
  String toString() {
    return 'LogDto(catId: $catId, type: ${type.name}, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogDto &&
          runtimeType == other.runtimeType &&
          catId == other.catId &&
          type == other.type &&
          recordedAt == other.recordedAt &&
          feedType == other.feedType &&
          feedAmount == other.feedAmount &&
          healthStatus == other.healthStatus &&
          spiritScore == other.spiritScore &&
          furScore == other.furScore &&
          hasInjury == other.hasInjury &&
          injuryDescription == other.injuryDescription &&
          weightEstimate == other.weightEstimate &&
          notes == other.notes &&
          locationHint == other.locationHint &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(
        catId,
        type,
        recordedAt,
        feedType,
        feedAmount,
        healthStatus,
        spiritScore,
        furScore,
        hasInjury,
        injuryDescription,
        weightEstimate,
        notes,
        locationHint,
        latitude,
        longitude,
      );
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
