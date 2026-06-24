import 'package:isar/isar.dart';

import '../../../../core/database/schemas/log_schema.dart';
import '../../domain/entities/log_entity.dart';
import '../../domain/enums/feed_type.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/repositories/log_repository.dart';

/// 日志仓库实现 — 基于 Isar 数据库
class LogRepositoryImpl implements LogRepository {
  final Isar _isar;
  LogRepositoryImpl(this._isar);

  Future<int> addLog(LogEntity log) async {
    try {
      final model = LogSchema()
        ..catId = log.catId
        ..type = log.type
        ..recordedAt = log.recordedAt
        ..createdAt = DateTime.now()
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

      return await _isar.writeTxn(() async {
        return await _isar.collection<LogSchema>().put(model);
      });
    } catch (e) {
      throw LogRepositoryException('添加日志失败: $e');
    }
  }

  Future<List<LogEntity>> getLogsByCatId(int catId) async {
    try {
      final models = await _isar.collection<LogSchema>()
          .filter()
          .catIdEqualTo(catId)
          .sortByRecordedAtDesc()
          .findAll();
      return models.map((m) => _toEntity(m)).toList();
    } catch (e) {
      throw LogRepositoryException('获取日志列表失败: $e');
    }
  }

  Future<LogEntity?> getLogById(int id) async {
    try {
      final model = await _isar.collection<LogSchema>().filter().idEqualTo(id).findFirst();
      return model != null ? _toEntity(model) : null;
    } catch (e) {
      throw LogRepositoryException('获取日志详情失败: $e');
    }
  }

  Future<List<LogEntity>> getAllLogs({int? limit, int? offset}) async {
    try {
      final models = await _isar.collection<LogSchema>()
          .where()
          .sortByRecordedAtDesc()
          .offset(offset ?? 0)
          .limit(limit ?? 50)
          .findAll();
      return models.map((m) => _toEntity(m)).toList();
    } catch (e) {
      throw LogRepositoryException('获取所有日志失败: $e');
    }
  }

  Future<int> getLogCount({int? catId}) async {
    try {
      if (catId != null) {
        return await _isar.collection<LogSchema>().filter().catIdEqualTo(catId).count();
      }
      return await _isar.collection<LogSchema>().count();
    } catch (e) {
      throw LogRepositoryException('获取日志数量失败: $e');
    }
  }

  Future<bool> deleteLog(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.collection<LogSchema>().delete(id);
      });
      return true;
    } catch (e) {
      throw LogRepositoryException('删除日志失败: $e');
    }
  }

  @override
  Future<bool> updateLog(LogEntity log) async {
    try {
      final schema = await _isar.collection<LogSchema>().filter().idEqualTo(log.id).findFirst();
      if (schema == null) return false;
      await _isar.writeTxn(() async {
        schema.catId = log.catId;
        schema.type = log.type;
        schema.recordedAt = log.recordedAt;
        schema.feedType = log.feedType ?? FeedType.other;
        schema.feedAmount = log.feedAmount ?? FeedAmount.medium;
        schema.healthStatus = log.healthStatus ?? HealthStatus.good;
        schema.spiritScore = log.spiritScore;
        schema.furScore = log.furScore;
        schema.hasInjury = log.hasInjury;
        schema.injuryDescription = log.injuryDescription;
        schema.weightEstimate = log.weightEstimate;
        schema.notes = log.notes;
        schema.locationHint = log.locationHint;
        schema.latitude = log.latitude;
        schema.longitude = log.longitude;
        await _isar.collection<LogSchema>().put(schema);
      });
      return true;
    } catch (e) {
      throw LogRepositoryException('更新日志失败: $e');
    }
  }

  Future<void> deleteLogsByCatId(int catId) async {
    try {
      final logs = await _isar.collection<LogSchema>().filter().catIdEqualTo(catId).findAll();
      await _isar.writeTxn(() async {
        for (final log in logs) {
          await _isar.collection<LogSchema>().delete(log.id);
        }
      });
    } catch (e) {
      throw LogRepositoryException('删除猫咪日志失败: $e');
    }
  }

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
}

class LogRepositoryException implements Exception {
  final String message;
  const LogRepositoryException(this.message);
  @override
  String toString() => 'LogRepositoryException: $message';
}
