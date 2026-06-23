import 'package:isar/isar.dart';

import '../../../../core/database/schemas/cat_schema.dart';
import '../../domain/entities/cat_entity.dart';

/// 猫咪本地数据源
///
/// 封装所有与 Isar 数据库交互的操作，为 Repository 层提供简洁的 CRUD 接口。
/// 该数据源负责：
/// - 将 [CatEntity] 转换为 [CatSchema] 进行持久化
/// - 将 [CatSchema] 查询结果转换为 [CatEntity] 返回给领域层
/// - 处理软删除逻辑（isDeleted 标记）
/// - 提供事务安全的写入操作
///
/// 使用方式：
/// ```dart
/// final datasource = CatLocalDataSource(isar);
/// final cats = await datasource.getAllCats();
/// ```
class CatLocalDataSource {
  /// Isar 数据库实例
  final Isar _isar;

  /// 构造函数，注入 Isar 数据库实例
  const CatLocalDataSource(this._isar);

  // ==================== 查询操作 ====================

  /// 获取所有猫咪列表
  ///
  /// [includeDeleted] 为 true 时返回包含已软删除的所有记录；
  /// 为 false 时仅返回未删除的记录。
  /// 结果按最近观察时间降序排列。
  Future<List<CatEntity>> getAllCats({bool includeDeleted = false}) async {
    final models = includeDeleted
        ? await _isar.catSchemas.where().sortByLastSeenAtDesc().findAll()
        : await _isar.catSchemas
            .filter()
            .isDeletedEqualTo(false)
            .sortByLastSeenAtDesc()
            .findAll();
    return models.map(_toEntity).toList();
  }

  /// 根据 ID 获取单只猫咪
  ///
  /// 返回 [CatEntity]，如果找不到对应 ID 的记录则返回 null。
  Future<CatEntity?> getCatById(int id) async {
    final model = await _isar.catSchemas.filter().idEqualTo(id).findFirst();
    return model != null ? _toEntity(model) : null;
  }

  /// 搜索猫咪
  ///
  /// 支持按昵称、位置提示、备注进行模糊搜索（不区分大小写）。
  /// 如果 [query] 为空，则返回所有未删除的猫咪。
  /// 结果按最近观察时间降序排列。
  Future<List<CatEntity>> searchCats(String query) async {
    if (query.trim().isEmpty) return getAllCats();
    final keyword = query.trim().toLowerCase();
    final models = await _isar.catSchemas
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group((q) => q
            .nicknameContains(keyword, caseSensitive: false)
            .or()
            .locationHintContains(keyword, caseSensitive: false)
            .or()
            .notesContains(keyword, caseSensitive: false))
        .sortByLastSeenAtDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  /// 获取猫咪总数
  ///
  /// [includeDeleted] 为 true 时统计所有记录；
  /// 为 false 时仅统计未删除的记录。
  Future<int> getCatCount({bool includeDeleted = false}) async {
    if (includeDeleted) return await _isar.catSchemas.count();
    return await _isar.catSchemas.filter().isDeletedEqualTo(false).count();
  }

  // ==================== 写入操作 ====================

  /// 添加一只新猫咪
  ///
  /// 将 [CatEntity] 转换为 [CatSchema] 并写入数据库。
  /// 自动设置 [createdAt] 和 [updatedAt] 为当前时间。
  /// 返回新创建记录的 ID。
  Future<int> addCat(CatEntity cat) async {
    final now = DateTime.now();
    final model = _toSchema(cat, createdAt: now, updatedAt: now);
    return await _isar.writeTxn(() async {
      return await _isar.catSchemas.put(model);
    });
  }

  /// 更新猫咪信息
  ///
  /// 根据 [CatEntity.id] 查找已有记录并更新字段。
  /// 如果找不到对应记录，抛出 [CatDataSourceException]。
  /// 自动更新 [updatedAt] 为当前时间。
  /// 返回是否更新成功。
  Future<bool> updateCat(CatEntity cat) async {
    final existing = await _isar.catSchemas.filter().idEqualTo(cat.id).findFirst();
    if (existing == null) {
      throw CatDataSourceException('找不到 ID=${cat.id} 的猫咪');
    }
    _updateSchemaFromEntity(existing, cat);
    existing.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.catSchemas.put(existing);
    });
    return true;
  }

  /// 删除猫咪
  ///
  /// [permanent] 为 true 时执行物理删除（从数据库中彻底移除）；
  /// 为 false 时执行软删除（标记 [isDeleted] = true）。
  /// 如果找不到对应记录，抛出 [CatDataSourceException]。
  /// 返回是否删除成功。
  Future<bool> deleteCat(int id, {bool permanent = false}) async {
    final existing = await _isar.catSchemas.filter().idEqualTo(id).findFirst();
    if (existing == null) {
      throw CatDataSourceException('找不到 ID=$id 的猫咪');
    }
    await _isar.writeTxn(() async {
      if (permanent) {
        await _isar.catSchemas.delete(existing.id);
      } else {
        existing.isDeleted = true;
        existing.updatedAt = DateTime.now();
        await _isar.catSchemas.put(existing);
      }
    });
    return true;
  }

  // ==================== 转换方法 ====================

  /// 将 [CatSchema] 数据库模型转换为 [CatEntity] 领域实体
  CatEntity _toEntity(CatSchema m) {
    return CatEntity(
      id: m.id,
      nickname: m.nickname,
      breed: m.breed,
      color: m.color,
      gender: m.gender,
      estimatedAgeMonths: m.estimatedAgeMonths,
      tags: m.tags.toList(),
      tnrStatus: m.tnrStatus,
      rarity: m.rarity,
      locationHint: m.locationHint,
      latitude: m.latitude,
      longitude: m.longitude,
      firstSeenAt: m.firstSeenAt,
      lastSeenAt: m.lastSeenAt,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      isDeleted: m.isDeleted,
      notes: m.notes,
      feedReminderHour: m.feedReminderHour,
      feedReminderMinute: m.feedReminderMinute,
      healthReminderHour: m.healthReminderHour,
      healthReminderMinute: m.healthReminderMinute,
      reminderEnabled: m.reminderEnabled,
    );
  }

  /// 将 [CatEntity] 领域实体转换为 [CatSchema] 数据库模型
  ///
  /// 用于新增记录时创建新的 Schema 实例。
  /// [createdAt] 和 [updatedAt] 为可选参数，用于指定时间戳。
  CatSchema _toSchema(
    CatEntity cat, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatSchema()
      ..nickname = cat.nickname
      ..breed = cat.breed
      ..color = cat.color
      ..gender = cat.gender
      ..estimatedAgeMonths = cat.estimatedAgeMonths
      ..tags = List<String>.from(cat.tags)
      ..tnrStatus = cat.tnrStatus
      ..rarity = cat.rarity
      ..locationHint = cat.locationHint
      ..latitude = cat.latitude
      ..longitude = cat.longitude
      ..firstSeenAt = cat.firstSeenAt
      ..lastSeenAt = cat.lastSeenAt
      ..createdAt = createdAt ?? cat.createdAt
      ..updatedAt = updatedAt ?? cat.updatedAt
      ..notes = cat.notes
      ..feedReminderHour = cat.feedReminderHour
      ..feedReminderMinute = cat.feedReminderMinute
      ..healthReminderHour = cat.healthReminderHour
      ..healthReminderMinute = cat.healthReminderMinute
      ..reminderEnabled = cat.reminderEnabled;
  }

  /// 将 [CatEntity] 的字段更新到已有的 [CatSchema] 实例
  ///
  /// 用于更新操作，直接修改已有实例的字段而非创建新实例，
  /// 以保留 Isar 对象的状态和关联关系。
  void _updateSchemaFromEntity(CatSchema schema, CatEntity entity) {
    schema
      ..nickname = entity.nickname
      ..breed = entity.breed
      ..color = entity.color
      ..gender = entity.gender
      ..estimatedAgeMonths = entity.estimatedAgeMonths
      ..tags = List<String>.from(entity.tags)
      ..tnrStatus = entity.tnrStatus
      ..rarity = entity.rarity
      ..locationHint = entity.locationHint
      ..latitude = entity.latitude
      ..longitude = entity.longitude
      ..lastSeenAt = entity.lastSeenAt
      ..isDeleted = entity.isDeleted
      ..notes = entity.notes
      ..feedReminderHour = entity.feedReminderHour
      ..feedReminderMinute = entity.feedReminderMinute
      ..healthReminderHour = entity.healthReminderHour
      ..healthReminderMinute = entity.healthReminderMinute
      ..reminderEnabled = entity.reminderEnabled;
  }
}

/// 数据源层异常
///
/// 当本地数据源操作失败时抛出此异常，
/// 例如数据库查询错误、记录未找到等。
class CatDataSourceException implements Exception {
  /// 异常描述信息
  final String message;

  /// 构造函数
  const CatDataSourceException(this.message);

  @override
  String toString() => 'CatDataSourceException: $message';
}
