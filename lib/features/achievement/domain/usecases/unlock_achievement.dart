import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/achievement_entity.dart';

part 'unlock_achievement.g.dart';

/// 成就仓库接口（前向引用）
///
/// 实际项目中应抽取到独立的 repository 文件中。
/// 此处为 UnlockAchievement UseCase 依赖的抽象接口。
abstract class AchievementRepository {
  /// 更新成就进度
  Future<void> updateAchievementProgress(String achievementId, int progress);

  /// 解锁成就
  Future<bool> unlockAchievement(String achievementId);

  /// 根据成就 ID 获取单个成就
  Future<AchievementEntity?> getAchievementById(String achievementId);
}

/// 解锁成就 UseCase
///
/// 处理成就解锁的业务逻辑，包括：
/// 1. 检查成就是否已解锁
/// 2. 更新成就进度
/// 3. 当进度达到目标值时自动解锁
/// 4. 返回解锁结果
class UnlockAchievement {
  final AchievementRepository _repository;

  const UnlockAchievement(this._repository);

  /// 执行解锁成就
  ///
  /// [achievementId] 要解锁的成就唯一标识。
  /// 返回 true 表示成功解锁，false 表示解锁失败或已解锁。
  ///
  /// 业务规则：
  /// - 如果成就已解锁，直接返回 false
  /// - 如果成就未解锁，将进度设置为目标值并解锁
  Future<bool> call(String achievementId) async {
    // 获取成就信息
    final achievement = await _repository.getAchievementById(achievementId);
    if (achievement == null) {
      return false;
    }

    // 已解锁则不重复解锁
    if (achievement.isUnlocked) {
      return false;
    }

    // 解锁成就
    return _repository.unlockAchievement(achievementId);
  }

  /// 增加成就进度
  ///
  /// [achievementId] 成就唯一标识。
  /// [increment] 进度增量（默认为 1）。
  /// 返回更新后的成就实体，如果成就不存在则返回 null。
  ///
  /// 当进度达到目标值时，自动触发解锁。
  Future<AchievementEntity?> incrementProgress(
    String achievementId, {
    int increment = 1,
  }) async {
    // 获取成就信息
    final achievement = await _repository.getAchievementById(achievementId);
    if (achievement == null) {
      return null;
    }

    // 已解锁则不再更新
    if (achievement.isUnlocked) {
      return achievement;
    }

    // 计算新进度（不超过目标值）
    final newProgress = (achievement.progress + increment)
        .clamp(0, achievement.target);

    // 更新进度
    await _repository.updateAchievementProgress(achievementId, newProgress);

    // 如果进度达到目标值，自动解锁
    if (newProgress >= achievement.target) {
      await _repository.unlockAchievement(achievementId);
    }

    // 返回更新后的成就
    return _repository.getAchievementById(achievementId);
  }

  /// 设置成就进度为指定值
  ///
  /// [achievementId] 成就唯一标识。
  /// [progress] 目标进度值。
  /// 返回更新后的成就实体，如果成就不存在则返回 null。
  Future<AchievementEntity?> setProgress(
    String achievementId,
    int progress,
  ) async {
    // 获取成就信息
    final achievement = await _repository.getAchievementById(achievementId);
    if (achievement == null) {
      return null;
    }

    // 已解锁则不再更新
    if (achievement.isUnlocked) {
      return achievement;
    }

    // 限制进度范围
    final clampedProgress = progress.clamp(0, achievement.target);

    // 更新进度
    await _repository.updateAchievementProgress(achievementId, clampedProgress);

    // 如果进度达到目标值，自动解锁
    if (clampedProgress >= achievement.target) {
      await _repository.unlockAchievement(achievementId);
    }

    // 返回更新后的成就
    return _repository.getAchievementById(achievementId);
  }

  /// 检查成就是否应该解锁
  ///
  /// [achievementId] 成就唯一标识。
  /// 返回 true 表示成就可以解锁（进度 >= 目标值且未解锁）。
  Future<bool> shouldUnlock(String achievementId) async {
    final achievement = await _repository.getAchievementById(achievementId);
    if (achievement == null) return false;
    return !achievement.isUnlocked && achievement.progress >= achievement.target;
  }
}

/// UnlockAchievement UseCase 的 Riverpod Provider
///
/// 使用 @riverpod 注解自动生成 Provider 代码。
/// 运行 `dart run build_runner build` 生成对应的 .g.dart 文件。
@riverpod
UnlockAchievement unlockAchievement(Ref ref, AchievementRepository repository) {
  return UnlockAchievement(repository);
}
