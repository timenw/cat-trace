import 'package:isar/isar.dart';

import '../../../core/database/schemas/log_schema.dart';
import '../../domain/entities/log_entity.dart';

/// 日志仓库实现 — 基于 Isar 数据库
class LogRepositoryImpl {
  final Isar _isar;
  LogRepositoryImpl(this._isar);

  Future<int> addLog(LogEntity log) async {
    try {
      final model = LogSchema()
        ..catId = log.catId
        ..type = log.type
        ..recordedAt = log.recordedAt
        ..createdAt = DateTime.now()
        ..feedType = log.feedType
        ..feedAmount = log.feedAmount
        ..healthStatus = log.healthStatus
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
        return await _isar.logSchemas.put(model);
      });
    } catch (e) {
      throw LogRepositoryException('添加日志失败: $e');
    }
  }

  Future<List<LogEntity>> getLogsByCatId(int catId) async {
    try {
      final models = await _isar.logSchemas
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
      final model = await _isar.logSchemas.filter().idEqualTo(id).findFirst();
      return model != null ? _toEntity(model) : null;
    } catch (e) {
      throw LogRepositoryException('获取日志详情失败: $e');
    }
  }

  Future<List<LogEntity>> getAllLogs({int? limit, int? offset}) async {
    try {
      final models = await _isar.logSchemas
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
        return await _isar.logSchemas.filter().catIdEqualTo(catId).count();
      }
      return await _isar.logSchemas.count();
    } catch (e) {
      throw LogRepositoryException('获取日志数量失败: $e');
    }
  }

  Future<bool> deleteLog(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.logSchemas.delete(id);
      });
      return true;
    } catch (e) {
      throw LogRepositoryException('删除日志失败: $e');
    }
  }

  Future<void> deleteLogsByCatId(int catId) async {
    try {
      final logs = await _isar.logSchemas.filter().catIdEqualTo(catId).findAll();
      await _isar.writeTxn(() async {
        for (final log in logs) {
          await _isar.logSchemas.delete(log.id);
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
