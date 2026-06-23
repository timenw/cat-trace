import 'package:isar/isar.dart';

import '../../../core/database/schemas/cat_schema.dart';
import '../../domain/entities/cat_entity.dart';
import '../../domain/repositories/cat_repository.dart';

/// 猫咪仓库实现 — 基于 Isar 数据库
class CatRepositoryImpl implements CatRepository {
  final Isar _isar;
  CatRepositoryImpl(this._isar);

  @override
  Future<List<CatEntity>> getAllCats({bool includeDeleted = false}) async {
    try {
      final models = includeDeleted
          ? await _isar.catSchemas.where().sortByLastSeenAtDesc().findAll()
          : await _isar.catSchemas.filter().isDeletedEqualTo(false).sortByLastSeenAtDesc().findAll();
      return models.map((m) => _toEntity(m)).toList();
    } catch (e) {
      throw CatRepositoryException('获取猫咪列表失败: $e');
    }
  }

  @override
  Future<CatEntity?> getCatById(int id) async {
    try {
      final model = await _isar.catSchemas.filter().idEqualTo(id).findFirst();
      return model != null ? _toEntity(model) : null;
    } catch (e) {
      throw CatRepositoryException('获取猫咪详情失败 (id=$id): $e');
    }
  }

  @override
  Future<List<CatEntity>> searchCats(String query) async {
    try {
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
      return models.map((m) => _toEntity(m)).toList();
    } catch (e) {
      throw CatRepositoryException('搜索猫咪失败: $e');
    }
  }

  @override
  Future<int> getCatCount({bool includeDeleted = false}) async {
    try {
      if (includeDeleted) return await _isar.catSchemas.count();
      return await _isar.catSchemas.filter().isDeletedEqualTo(false).count();
    } catch (e) {
      throw CatRepositoryException('获取猫咪总数失败: $e');
    }
  }

  @override
  Future<int> addCat(CatEntity cat) async {
    try {
      final now = DateTime.now();
      final model = CatSchema()
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
        ..createdAt = now
        ..updatedAt = now
        ..notes = cat.notes
        ..feedReminderHour = cat.feedReminderHour
        ..feedReminderMinute = cat.feedReminderMinute
        ..healthReminderHour = cat.healthReminderHour
        ..healthReminderMinute = cat.healthReminderMinute
        ..reminderEnabled = cat.reminderEnabled;

      return await _isar.writeTxn(() async {
        return await _isar.catSchemas.put(model);
      });
    } catch (e) {
      throw CatRepositoryException('添加猫咪失败: $e');
    }
  }

  @override
  Future<bool> updateCat(CatEntity cat) async {
    try {
      final existing = await _isar.catSchemas.filter().idEqualTo(cat.id).findFirst();
      if (existing == null) throw CatRepositoryException('找不到 ID=${cat.id} 的猫咪');

      existing
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
        ..lastSeenAt = cat.lastSeenAt
        ..updatedAt = DateTime.now()
        ..isDeleted = cat.isDeleted
        ..notes = cat.notes
        ..feedReminderHour = cat.feedReminderHour
        ..feedReminderMinute = cat.feedReminderMinute
        ..healthReminderHour = cat.healthReminderHour
        ..healthReminderMinute = cat.healthReminderMinute
        ..reminderEnabled = cat.reminderEnabled;

      await _isar.writeTxn(() async {
        await _isar.catSchemas.put(existing);
      });
      return true;
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('更新猫咪失败: $e');
    }
  }

  @override
  Future<bool> deleteCat(int id, {bool permanent = false}) async {
    try {
      final existing = await _isar.catSchemas.filter().idEqualTo(id).findFirst();
      if (existing == null) throw CatRepositoryException('找不到 ID=$id 的猫咪');

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
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('删除猫咪失败: $e');
    }
  }

  /// CatSchema → CatEntity
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
}

class CatRepositoryException implements Exception {
  final String message;
  const CatRepositoryException(this.message);
  @override
  String toString() => 'CatRepositoryException: $message';
}
