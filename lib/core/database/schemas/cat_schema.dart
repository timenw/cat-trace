import 'package:isar/isar.dart';
import '../../features/cat/domain/enums/cat_breed.dart';
import '../../features/cat/domain/enums/cat_color.dart';
import '../../features/cat/domain/enums/tnr_status.dart';
import '../../features/cat/domain/enums/rarity.dart';
import '../../features/cat/domain/entities/cat_entity.dart'
    show CatGender;
import 'photo_schema.dart';
import 'log_schema.dart';

part 'cat_schema.g.dart';

/// 猫咪数据模型
@collection
class CatSchema {
  Id id = Isar.autoIncrement;

  /// 昵称
  @Index(type: IndexType.value)
  String? nickname;

  /// 品种
  @enumerated
  CatBreed breed = CatBreed.unknown;

  /// 毛色
  @enumerated
  CatColor color = CatColor.unknown;

  /// 性别: unknown, male, female
  @Index()
  @enumerated
  CatEntityGender gender = CatEntityGender.unknown;

  /// 估算年龄（月）
  int? estimatedAgeMonths;

  /// 特征标签
  List<String> tags = [];

  /// TNR 状态
  @enumerated
  TnrStatus tnrStatus = TnrStatus.none;

  /// 稀有度
  @enumerated
  Rarity rarity = Rarity.common;

  /// 发现位置描述（模糊）
  String? locationHint;

  /// 纬度（可选，默认关闭）
  double? latitude;

  /// 经度（可选，默认关闭）
  double? longitude;

  /// 首次发现时间
  DateTime firstSeenAt = DateTime.now();

  /// 最近观察时间
  DateTime lastSeenAt = DateTime.now();

  /// 创建时间
  DateTime createdAt = DateTime.now();

  /// 更新时间
  DateTime updatedAt = DateTime.now();

  /// 是否已删除（软删除）
  bool isDeleted = false;

  /// 备注
  String? notes;

  /// 关联的照片
  final photos = IsarLinks<PhotoSchema>();

  /// 关联的日志
  final logs = IsarLinks<LogSchema>();

  /// 投喂提醒时间（小时）
  int? feedReminderHour;

  /// 投喂提醒时间（分钟）
  int? feedReminderMinute;

  /// 健康观察提醒时间（小时）
  int? healthReminderHour;

  /// 健康观察提醒时间（分钟）
  int? healthReminderMinute;

  /// 提醒是否开启
  bool reminderEnabled = false;

  /// 计算属性：日志数量
  int get logCount => logs.length;

  /// 计算属性：照片数量
  int get photoCount => photos.length;
}
