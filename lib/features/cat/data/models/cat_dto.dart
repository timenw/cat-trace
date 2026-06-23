import '../../domain/entities/cat_entity.dart';
import '../../domain/enums/cat_breed.dart';
import '../../domain/enums/cat_color.dart';
import '../../domain/enums/tnr_status.dart';
import '../../domain/enums/rarity.dart';

/// 猫咪识别结果 DTO（Data Transfer Object）
///
/// 用于将 AI 图像识别结果从识别模块传输到数据层。
/// 当用户拍摄或上传一张猫咪照片后，AI 模型会返回识别结果，
/// 本 DTO 封装了识别结果的各个字段，方便在不同层之间传递数据。
///
/// 与 [CatEntity] 的区别：
/// - CatDTO 不包含数据库 ID、时间戳等持久化字段
/// - CatDTO 的字段均为可识别/可编辑的，用于用户确认和修改
/// - CatDTO 支持 JSON 序列化，便于与 AI 服务通信
///
/// 使用场景：
/// ```dart
/// // AI 识别结果 → CatDTO
/// final dto = CatDto.fromAiResult(aiResponse);
///
/// // CatDTO → CatEntity（用户确认后保存到数据库）
/// final entity = dto.toEntity();
/// ```
class CatDto {
  /// AI 识别出的猫咪昵称建议（可为 null，由用户自行填写）
  final String? nickname;

  /// AI 识别出的品种
  final CatBreed breed;

  /// AI 识别出的毛色
  final CatColor color;

  /// AI 识别出的性别（基于外观推测，可能不准确）
  final CatGender gender;

  /// AI 估算的年龄（单位：月）
  final int? estimatedAgeMonths;

  /// AI 识别出的特征标签（如 ["亲人", "大尾巴", "异瞳"]）
  final List<String> tags;

  /// AI 判断的 TNR 状态（基于是否有耳缺等外观特征）
  final TnrStatus tnrStatus;

  /// AI 评估的稀有度
  final Rarity rarity;

  /// 识别结果的置信度（0.0 ~ 1.0）
  /// 1.0 表示完全确定，0.0 表示完全不确定
  final double confidence;

  /// AI 识别的原始描述文本
  final String? description;

  /// 构造函数
  const CatDto({
    this.nickname,
    this.breed = CatBreed.unknown,
    this.color = CatColor.unknown,
    this.gender = CatGender.unknown,
    this.estimatedAgeMonths,
    this.tags = const [],
    this.tnrStatus = TnrStatus.none,
    this.rarity = Rarity.common,
    this.confidence = 0.0,
    this.description,
  });

  /// 从 AI 识别结果的 JSON Map 创建 CatDto 实例
  ///
  /// AI 服务返回的 JSON 格式示例：
  /// ```json
  /// {
  ///   "breed": "siamese",
  ///   "color": "pointed",
  ///   "gender": "female",
  ///   "estimated_age_months": 8,
  ///   "tags": ["蓝眼睛", "修长"],
  ///   "tnr_status": "earTip",
  ///   "rarity": "uncommon",
  ///   "confidence": 0.92,
  ///   "description": "一只蓝色眼睛的暹罗猫，耳朵有缺角"
  /// }
  /// ```
  factory CatDto.fromAiResult(Map<String, dynamic> json) {
    return CatDto(
      nickname: json['nickname'] as String?,
      breed: json['breed'] != null
          ? CatBreed.fromString(json['breed'] as String)
          : CatBreed.unknown,
      color: json['color'] != null
          ? CatColor.fromString(json['color'] as String)
          : CatColor.unknown,
      gender: _parseGender(json['gender'] as String?),
      estimatedAgeMonths: json['estimated_age_months'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tnrStatus: json['tnr_status'] != null
          ? TnrStatus.fromString(json['tnr_status'] as String)
          : TnrStatus.none,
      rarity: json['rarity'] != null
          ? Rarity.fromString(json['rarity'] as String)
          : Rarity.common,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
    );
  }

  /// 将 CatDto 转换为 JSON Map
  ///
  /// 用于将识别结果发送给后端服务或本地缓存。
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'breed': breed.name,
      'color': color.name,
      'gender': gender.name,
      'estimatedAgeMonths': estimatedAgeMonths,
      'tags': tags,
      'tnrStatus': tnrStatus.name,
      'rarity': rarity.name,
      'confidence': confidence,
      'description': description,
    };
  }

  /// 将 CatDto 转换为 CatEntity
  ///
  /// 用于用户确认 AI 识别结果后，将 DTO 数据保存到数据库。
  /// 注意：生成的 Entity ID 为 0（表示新增），
  /// 时间戳会设置为当前时间。
  CatEntity toEntity() {
    final now = DateTime.now();
    return CatEntity(
      id: 0, // 新增记录，ID 由数据库自动生成
      nickname: nickname,
      breed: breed,
      color: color,
      gender: gender,
      estimatedAgeMonths: estimatedAgeMonths,
      tags: List<String>.from(tags),
      tnrStatus: tnrStatus,
      rarity: rarity,
      locationHint: null, // AI 识别不包含位置信息
      latitude: null,
      longitude: null,
      firstSeenAt: now,
      lastSeenAt: now,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      notes: description, // 将 AI 描述作为初始备注
      feedReminderHour: null,
      feedReminderMinute: null,
      healthReminderHour: null,
      healthReminderMinute: null,
      reminderEnabled: false,
    );
  }

  /// 创建 CatDto 的副本，可选择性地更新部分字段
  ///
  /// 用于用户修改 AI 识别结果后更新 DTO。
  CatDto copyWith({
    String? nickname,
    CatBreed? breed,
    CatColor? color,
    CatGender? gender,
    int? estimatedAgeMonths,
    List<String>? tags,
    TnrStatus? tnrStatus,
    Rarity? rarity,
    double? confidence,
    String? description,
  }) {
    return CatDto(
      nickname: nickname ?? this.nickname,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      gender: gender ?? this.gender,
      estimatedAgeMonths: estimatedAgeMonths ?? this.estimatedAgeMonths,
      tags: tags ?? this.tags,
      tnrStatus: tnrStatus ?? this.tnrStatus,
      rarity: rarity ?? this.rarity,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
    );
  }

  /// 判断识别结果是否可信
  ///
  /// 当置信度 >= 0.7 时认为识别结果可信，
  /// 可以直接用于创建猫咪记录。
  bool get isConfident => confidence >= 0.7;

  /// 获取置信度的百分比显示文本
  String get confidenceDisplayText => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'CatDto(breed: ${breed.displayName}, color: ${color.displayName}, '
        'gender: ${gender.name}, confidence: $confidenceDisplayText)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatDto &&
          runtimeType == other.runtimeType &&
          nickname == other.nickname &&
          breed == other.breed &&
          color == other.color &&
          gender == other.gender &&
          estimatedAgeMonths == other.estimatedAgeMonths &&
          _listEquals(tags, other.tags) &&
          tnrStatus == other.tnrStatus &&
          rarity == other.rarity &&
          confidence == other.confidence &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
        nickname,
        breed,
        color,
        gender,
        estimatedAgeMonths,
        Object.hashAll(tags),
        tnrStatus,
        rarity,
        confidence,
        description,
      );
}

/// 解析猫咪性别枚举
///
/// 支持多种输入格式：
/// - "male" / "公" / "公猫" → CatGender.male
/// - "female" / "母" / "母猫" → CatGender.female
/// - 其他 → CatGender.unknown
CatGender _parseGender(String? value) {
  if (value == null) return CatGender.unknown;
  switch (value.toLowerCase()) {
    case 'male':
    case '公':
    case '公猫':
      return CatGender.male;
    case 'female':
    case '母':
    case '母猫':
      return CatGender.female;
    default:
      return CatGender.unknown;
  }
}

/// 列表相等比较辅助函数
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 猫咪识别结果批量 DTO
///
/// 当 AI 一次识别出多只猫咪时使用。
/// 包含多个 [CatDto] 实例和整体识别元数据。
class CatBatchDto {
  /// 识别出的猫咪列表
  final List<CatDto> cats;

  /// 原始图片的文件路径（可选）
  final String? imagePath;

  /// 识别耗时（毫秒）
  final int? processingTimeMs;

  /// 使用的 AI 模型名称
  final String? modelName;

  /// 构造函数
  const CatBatchDto({
    this.cats = const [],
    this.imagePath,
    this.processingTimeMs,
    this.modelName,
  });

  /// 从 AI 批量识别结果 JSON 创建
  factory CatBatchDto.fromJson(Map<String, dynamic> json) {
    final catsList = (json['cats'] as List<dynamic>?)
            ?.map((e) => CatDto.fromAiResult(e as Map<String, dynamic>))
            .toList() ??
        const [];
    return CatBatchDto(
      cats: catsList,
      imagePath: json['image_path'] as String?,
      processingTimeMs: json['processing_time_ms'] as int?,
      modelName: json['model_name'] as String?,
    );
  }

  /// 转换为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'cats': cats.map((c) => c.toJson()).toList(),
      'imagePath': imagePath,
      'processingTimeMs': processingTimeMs,
      'modelName': modelName,
    };
  }

  /// 是否识别到猫咪
  bool get hasResults => cats.isNotEmpty;

  /// 识别到的猫咪数量
  int get count => cats.length;

  @override
  String toString() => 'CatBatchDto(count: $count, model: $modelName)';
}
