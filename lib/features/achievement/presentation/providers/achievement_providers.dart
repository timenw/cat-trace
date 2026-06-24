import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement_entity.dart';
import '../../domain/usecases/get_achievements.dart';
import '../../domain/usecases/unlock_achievement.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/database/schemas/achievement_schema.dart';
import '../../../../shared/models/result.dart';

part 'achievement_providers.g.dart';

// ============================================================================
// 数据源 & 仓库 Provider
// ============================================================================

/// 成就仓库 Provider（基于 Isar 的直接实现）
///
/// 不使用传统 repository 模式，而是直接在 Provider 中操作 Isar 数据库，
/// 因为成就系统是简单的 CRUD + 查询，不需要复杂的抽象层。
final achievementDataProvider = Provider<AchievementDataProvider>((ref) {
  return AchievementDataProvider(IsarDatabase.instance);
});

/// 成就数据提供者
///
/// 封装 Isar AchievementSchema 的 CRUD 操作。
/// 虽然不使用 implements 声明，但此类包含了 AchievementRepository（两个版本）所需的全部方法。
class AchievementDataProvider {
  final Isar _isar;

  AchievementDataProvider(this._isar);

  /// 获取所有成就
  Future<List<AchievementEntity>> getAllAchievements() async {
    final schemas = await _isar.collection<AchievementSchema>().where().findAll();
    return schemas.map(_toEntity).toList();
  }

  /// 按分类获取成就
  Future<List<AchievementEntity>> getAchievementsByCategory(
      AchievementCategory category) async {
    final schemas = await _isar.collection<AchievementSchema>()
        .filter()
        .categoryEqualTo(category.name)
        .findAll();
    return schemas.map(_toEntity).toList();
  }

  /// 获取已解锁的成就
  Future<List<AchievementEntity>> getUnlockedAchievements() async {
    final schemas = await _isar.collection<AchievementSchema>()
        .filter()
        .isUnlockedEqualTo(true)
        .sortBySortOrder()
        .findAll();
    return schemas.map(_toEntity).toList();
  }

  /// 根据 achievementId 获取单个成就
  Future<AchievementEntity?> getAchievementById(String achievementId) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    return schema == null ? null : _toEntity(schema);
  }

  /// 更新成就进度
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    if (schema != null) {
      await _isar.writeTxn(() async {
        schema.progress = progress;
        schema.target = progress > schema.target ? progress : schema.target;
        await _isar.put(schema);
      });
    }
  }

  /// 解锁成就
  Future<bool> unlockAchievement(String achievementId) async {
    final schema = await _isar.collection<AchievementSchema>()
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    if (schema != null && !schema.isUnlocked) {
      await _isar.writeTxn(() async {
        schema.isUnlocked = true;
        schema.unlockedAt = DateTime.now();
        await _isar.put(schema);
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
// UseCase Provider
// ============================================================================

/// 获取成就列表 UseCase Provider
@riverpod
GetAchievements getAchievements(GetAchievementsRef ref) {
  final dataProvider = ref.watch(achievementDataProvider);
  return GetAchievements(dataProvider);
}

/// 解锁成就 UseCase Provider
@riverpod
UnlockAchievement unlockAchievement(UnlockAchievementRef ref) {
  final dataProvider = ref.watch(achievementDataProvider);
  return UnlockAchievement(dataProvider);
}

// ============================================================================
// 状态管理 Provider
// ============================================================================

/// 成就列表 FutureProvider
///
/// 加载所有成就数据，用于成就页面展示。
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
///
/// 返回一个可调用函数，传入 achievementId 执行解锁。
final unlockAchievementActionProvider =
    Provider<Future<bool> Function(String)>((ref) {
  final usecase = ref.watch(unlockAchievementProvider);
  return (achievementId) => usecase(achievementId);
});

/// 增加成就进度操作 Provider
///
/// 返回一个可调用函数，传入 achievementId 和增量值。
final incrementAchievementProgressProvider =
    Provider<Future<AchievementEntity?> Function(String, {int increment})>((ref) {
  final usecase = ref.watch(unlockAchievementProvider);
  return (achievementId, {int increment = 1}) =>
      usecase.incrementProgress(achievementId, increment: increment);
});

/// 刷新成就列表的刷新指示器
final refreshAchievementsProvider = StateProvider<bool>((ref) => false);
