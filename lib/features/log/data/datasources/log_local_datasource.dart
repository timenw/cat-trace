import 'package:isar/isar.dart';

import '../../../../core/database/schemas/log_schema.dart';
import '../../domain/entities/log_entity.dart';

/// 日志本地数据源
///
/// 封装所有与 Isar 数据库交互的日志操作，为 Repository 层提供简洁的 CRUD 接口。
/// 该数据源负责：
/// - 将 [LogEntity] 转换为 [LogSchema] 进行持久化
/// - 将 [LogSchema] 查询结果转换为 [LogEntity] 返回给领域层
/// - 提供事务安全的写入操作
/// - 支持按猫咪 ID、日志类型等多种条件查询
///
/// 使用方式：
/// ```dart
/// final datasource = LogLocalDataSource(isar);
/// final logs = await datasource.getLogsByCatId(1);
/// ```
class LogLocalDataSource {
  /// Isar 数据库实例
  final Isar _isar;

  /// 构造函数，注入 Isar 数据库实例
  const LogLocalDataSource(this._isar);

  // ==================== 查询操作 ====================

  /// 根据猫咪 ID 获取日志列表
  ///
  /// 返回按记录时间降序排列的日志列表。
  /// 如果找不到对应猫咪的日志，返回空列表。
  Future<List<LogEntity>> getLogsByCatId(int catId) async {
    final models = await _isar.collection<LogSchema>()
        .filter()
        .catIdEqualTo(catId)
        .sortByRecordedAtDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  /// 根据日志 ID 获取单条日志
  ///
  /// 返回 [LogEntity]，如果找不到对应 ID 的记录则返回 null。
  Future<LogEntity?> getLogById(int id) async {
    final model = await _isar.collection<LogSchema>().filter().idEqualTo(id).findFirst();
    return model != null ? _toEntity(model) : null;
  }

  /// 获取所有日志
  ///
  /// [limit] 限制返回数量，默认为 50。
  /// [offset] 偏移量，用于分页，默认为 0。
  /// 结果按记录时间降序排列。
  Future<List<LogEntity>> getAllLogs({int? limit, int? offset}) async {
    final models = await _isar.collection<LogSchema>()
        .where()
        .sortByRecordedAtDesc()
        .offset(offset ?? 0)
        .limit(limit ?? 50)
        .findAll();
    return models.map(_toEntity).toList();
  }

  /// 获取日志总数
  ///
  /// [catId] 为指定猫咪 ID 时，仅统计该猫咪的日志数量；
  /// 为 null 时统计所有日志数量。
  Future<int> getLogCount({int? catId}) async {
    if (catId != null) {
      return await _isar.collection<LogSchema>().filter().catIdEqualTo(catId).count();
    }
    return await _isar.collection<LogSchema>().count();
  }

  // ==================== 写入操作 ====================

  /// 添加一条新日志
  ///
  /// 将 [LogEntity] 转换为 [LogSchema] 并写入数据库。
  /// 自动设置 [createdAt] 为当前时间。
  /// 返回新创建记录的 ID。
  Future<int> addLog(LogEntity log) async {
    final model = _toSchema(log, createdAt: DateTime.now());
    return await _isar.writeTxn(() async {
      return await _isar.collection<LogSchema>().put(model);
    });
  }

  /// 更新日志
  ///
  /// 根据 [LogEntity.id] 查找已有记录并更新字段。
  /// 如果找不到对应记录，抛出 [LogDataSourceException]。
  /// 返回是否更新成功。
  Future<bool> updateLog(LogEntity log) async {
    final existing =
        await _isar.collection<LogSchema>().filter().idEqualTo(log.id).findFirst();
    if (existing == null) {
      throw LogDataSourceException('找不到 ID=${log.id} 的日志');
    }
    _updateSchemaFromEntity(existing, log);
    await _isar.writeTxn(() async {
      await _isar.collection<LogSchema>().put(existing);
    });
    return true;
  }

  /// 删除日志
  ///
  /// 根据日志 ID 执行物理删除。
  /// 如果找不到对应记录，抛出 [LogDataSourceException]。
  /// 返回是否删除成功。
  Future<bool> deleteLog(int id) async {
    final existing = await _isar.collection<LogSchema>().filter().idEqualTo(id).findFirst();
    if (existing == null) {
      throw LogDataSourceException('找不到 ID=$id 的日志');
    }
    await _isar.writeTxn(() async {
      await _isar.collection<LogSchema>().delete(existing.id);
    });
    return true;
  }

  /// 删除指定猫咪的所有日志
  ///
  /// 当删除猫咪时，需要同时删除该猫咪的所有日志记录。
  /// 使用事务确保操作的原子性。
  Future<void> deleteLogsByCatId(int catId) async {
    final logs =
        await _isar.collection<LogSchema>().filter().catIdEqualTo(catId).findAll();
    await _isar.writeTxn(() async {
      for (final log in logs) {
        await _isar.collection<LogSchema>().delete(log.id);
      }
    });
  }

  // ==================== 转换方法 ====================

  /// 将 [LogSchema] 数据库模型转换为 [LogEntity] 领域实体
  LogEntity _toEntity(LogSchema m) {
    return LogEntity(
      id: m.id,
      catId: m.catId,
      type: m.type,
      recordedAt: m.recordedAt,
      createdAt: m.createdAt,
      feedType: m.feedType,
      feedAmount: m.feedAmount,
      healthStatus: m.healthStatus,
      spiritScore: m.spiritScore,
      furScore: m.furScore,
      hasInjury: m.hasInjury,
      injuryDescription: m.injuryDescription,
      weightEstimate: m.weightEstimate,
      notes: m.notes,
      locationHint: m.locationHint,
      latitude: m.latitude,
      longitude: m.longitude,
    );
  }

  /// 将 [LogEntity] 领域实体转换为 [LogSchema] 数据库模型
  ///
  /// 用于新增记录时创建新的 Schema 实例。
  /// [createdAt] 为可选参数，用于指定创建时间戳。
  LogSchema _toSchema(LogEntity log, {DateTime? createdAt}) {
    return LogSchema()
      ..catId = log.catId
      ..type = log.type
      ..recordedAt = log.recordedAt
      ..createdAt = createdAt ?? log.createdAt
      ..feedType = log.feedType ?? FeedType.other
      ..feedAmount = log.feedAmount ?? FeedAmount.medium
      ..healthStatus = log.healthStatus ?? HealthStatus.good
      ..spiritScore = log.spiritScore
      ..furScore = log.furScore
      ..hasInjury = log.hasInjury
      ..injuryDescription = log.injuryDescription
      ..weightEstimate = log.weightEstimate
      ..notes = log.notes
      ..locationHint = log.locationHint
      ..latitude = log.latitude
      ..longitude = log.longitude;
  }

  /// 将 [LogEntity] 的字段更新到已有的 [LogSchema] 实例
  ///
  /// 用于更新操作，直接修改已有实例的字段而非创建新实例，
  /// 以保留 Isar 对象的状态和关联关系。
  void _updateSchemaFromEntity(LogSchema schema, LogEntity entity) {
    schema
      ..catId = entity.catId
      ..type = entity.type
      ..recordedAt = entity.recordedAt
      ..feedType = entity.feedType ?? FeedType.other
      ..feedAmount = entity.feedAmount ?? FeedAmount.medium
      ..healthStatus = entity.healthStatus ?? HealthStatus.good
      ..spiritScore = entity.spiritScore
      ..furScore = entity.furScore
      ..hasInjury = entity.hasInjury
      ..injuryDescription = entity.injuryDescription
      ..weightEstimate = entity.weightEstimate
      ..notes = entity.notes
      ..locationHint = entity.locationHint
      ..latitude = entity.latitude
      ..longitude = entity.longitude;
  }
}

/// 数据源层异常
///
/// 当本地数据源操作失败时抛出此异常，
/// 例如数据库查询错误、记录未找到等。
class LogDataSourceException implements Exception {
  /// 异常描述信息
  final String message;

  /// 构造函数
  const LogDataSourceException(this.message);

  @override
  String toString() => 'LogDataSourceException: $message';
}
