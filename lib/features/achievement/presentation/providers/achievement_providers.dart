import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement_entity.dart';
import '../../domain/usecases/get_achievements.dart' as get_achievements_uc;
import '../../domain/usecases/unlock_achievement.dart' as unlock_achievements_uc;
import '../../../../core/database/isar_database.dart';
import '../../../../core/database/schemas/achievement_schema.dart';

part 'achievement_providers.g.dart';

// ============================================================================
// 仓库实现 — 同时满足两个 UseCase 的接口需求
// ============================================================================

/// 成就数据提供者 — 实现两个 UseCase 的 Repository 接口
class AchievementDataProvider implements get_achievements_uc.AchievementRepository, unlock_achievements_uc.AchievementRepository {
  final Isar _isar;

  AchievementDataProvider(this._isar);

  // --- get_achievements_uc.AchievementRepository 方法 ---
  @override
  Future<List<AchievementEntity>> getAllAchievements() async {
    final schemas = await _isar.collection<AchievementSchema>().where().findAll();
    return schemas.map(_toEntity).toList();
  }

  @override
  Future<List<AchievementEntity>> getAchievementsByCategory(
      AchievementCategory category) async {
    final schemas = await _isar.collection<AchievementSchema>()
        .filter()
        .categoryEqualTo(category)
        .findAll();
    return schemas.map(_toEntity).toList();
  }

  @override
  Future<List<AchievementEntity>> getUnlockedAchievements() async {
    final schemas = await _isar.collection<AchievementSchema>()
        .filter()
        .isUnlockedEqualTo(true)
        .sortBySortOrder()
        .findAll();
    return schemas.map(_toEntity).toList();
  }

  @override
  Future<AchievementEntity?> getAchievementById(String achievementId) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    return schema == null ? null : _toEntity(schema);
  }

  // --- unlock_achievements_uc.AchievementRepository 方法 ---
  @override
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    if (schema != null) {
      await _isar.writeTxn(() async {
        schema.progress = progress;
        schema.target = progress > schema.target ? progress : schema.target;
        await _isar.collection<AchievementSchema>().put(schema);
      });
    }
  }

  @override
  Future<bool> unlockAchievement(String achievementId) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    if (schema != null && !schema.isUnlocked) {
      await _isar.writeTxn(() async {
        schema.isUnlocked = true;
        schema.unlockedAt = DateTime.now();
        await _isar.collection<AchievementSchema>().put(schema);
      });
      return true;
    }
    return false;
  }

  /// 将 AchievementSchema 转换为 AchievementEntity
  AchievementEntity _toEntity(AchievementSchema schema) {
    return AchievementEntity(
      id: schema.id,
      achievementId: schema.achievementId,
      name: schema.name,
      description: schema.description,
      icon: schema.icon,
      rarity: schema.rarity,
      isUnlocked: schema.isUnlocked,
      unlockedAt: schema.unlockedAt,
      progress: schema.progress,
      target: schema.target,
      category: schema.category,
      sortOrder: schema.sortOrder,
    );
  }
}

// ============================================================================
// 数据源 Provider
// ============================================================================

final _achievementDataProvider = Provider<AchievementDataProvider>((ref) {
  return AchievementDataProvider(IsarDatabase.instance);
});

// ============================================================================
// UseCase Provider
// ============================================================================

/// 获取成就列表 UseCase Provider
@riverpod
get_achievements_uc.GetAchievements getAchievements(GetAchievementsRef ref) {
  final dataProvider = ref.watch(_achievementDataProvider);
  return get_achievements_uc.GetAchievements(dataProvider);
}

/// 解锁成就 UseCase Provider
@riverpod
unlock_achievements_uc.UnlockAchievement unlockAchievement(UnlockAchievementRef ref) {
  final dataProvider = ref.watch(_achievementDataProvider);
  return unlock_achievements_uc.UnlockAchievement(dataProvider);
}

// ============================================================================
// 状态管理 Provider
// ============================================================================

/// 成就列表 FutureProvider
final achievementsProvider =
    FutureProvider<List<AchievementEntity>>((ref) async {
  final usecase = ref.watch(getAchievementsProvider);
  return usecase.getAll();
});

/// 已解锁成就列表 Provider
final unlockedAchievementsProvider =
    FutureProvider<List<AchievementEntity>>((ref) async {
  final usecase = ref.watch(getAchievementsProvider);
  return usecase.getUnlocked();
});

/// 按分类筛选的成就列表 Provider
final achievementsByCategoryProvider =
    FutureProvider.family<List<AchievementEntity>, AchievementCategory>((ref, category) async {
  final usecase = ref.watch(getAchievementsProvider);
  return usecase.call(category: category);
});

/// 单个成就 Provider（Family）
final achievementDetailProvider =
    FutureProvider.family<AchievementEntity?, String>((ref, achievementId) async {
  final usecase = ref.watch(getAchievementsProvider);
  return usecase.getById(achievementId);
});

/// 解锁成就操作 Provider
final unlockAchievementActionProvider =
    Provider<Future<bool> Function(String)>((ref) {
  final usecase = ref.watch(unlockAchievementProvider);
  return (achievementId) => usecase(achievementId);
});

/// 增加成就进度操作 Provider
final incrementAchievementProgressProvider =
    Provider<Future<AchievementEntity?> Function(String, {int increment})>((ref) {
  final usecase = ref.watch(unlockAchievementProvider);
  return (achievementId, {int increment = 1}) =>
      usecase.incrementProgress(achievementId, increment: increment);
});

/// 刷新成就列表的刷新指示器
final refreshAchievementsProvider = StateProvider<bool>((ref) => false);
