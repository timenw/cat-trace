import 'package:isar/isar.dart';

part 'photo_schema.g.dart';

/// 照片数据模型
@collection
class PhotoSchema {
  Id id = Isar.autoIncrement;

  /// 关联的猫咪 ID
  @Index()
  int? catId;

  /// 关联的日志 ID
  @Index()
  int? logId;

  /// 文件路径（本地存储）
  @Index(type: IndexType.hash)
  String filePath = '';

  /// 缩略图路径
  String? thumbnailPath;

  /// 拍摄/创建时间
  DateTime takenAt = DateTime.now();

  /// 创建时间
  DateTime createdAt = DateTime.now();

  /// 文件大小 (bytes)
  int fileSize = 0;

  /// 宽度
  int width = 0;

  /// 高度
  int height = 0;

  /// 是否包含水印
  bool hasWatermark = false;

  /// 水印文本
  String? watermarkText;

  /// 序号（排序用）
  int sortOrder = 0;

  /// 是否已删除（软删除）
  bool isDeleted = false;
}
