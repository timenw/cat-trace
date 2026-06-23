import 'package:isar/isar.dart';
import '../../../features/log/domain/enums/log_type.dart';
import '../../../features/log/domain/enums/feed_type.dart';
import '../../../features/log/domain/enums/health_status.dart';
import '../../../features/log/domain/entities/log_entity.dart'
    show FeedAmount;
import 'photo_schema.dart';

part 'log_schema.g.dart';

/// 日志数据模型
@collection
class LogSchema {
  Id id = Isar.autoIncrement;

  /// 关联的猫咪 ID
  @Index()
  int catId = 0;

  /// 日志类型
  @enumerated
  LogType type = LogType.feed;

  /// 记录时间
  @Index()
  DateTime recordedAt = DateTime.now();

  /// 创建时间
  DateTime createdAt = DateTime.now();

  /// ====== 投喂相关 ======
  /// 食物类型
  @enumerated
  FeedType? feedType;

  /// 投喂量: small, medium, large
  @enumerated
  FeedAmount? feedAmount;

  /// ====== 健康观察相关 ======
  /// 整体健康状态
  @enumerated
  HealthStatus? healthStatus;

  /// 精神状态评分 (1-5)
  int? spiritScore;

  /// 毛发状态评分 (1-5)
  int? furScore;

  /// 是否有伤病
  bool? hasInjury;

  /// 伤病描述
  String? injuryDescription;

  /// 体重估算 (kg)
  double? weightEstimate;

  /// ====== 通用 ======
  /// 备注
  String? notes;

  /// 关联的照片
  final photos = IsarLinks<PhotoSchema>();

  /// 位置描述（模糊）
  String? locationHint;

  /// 纬度（可选）
  double? latitude;

  /// 经度（可选）
  double? longitude;
}
