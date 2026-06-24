import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/achievement_entity.dart';

part 'get_achievements.g.dart';

/// 成就仓库接口（前向引用）
///
/// 实际项目中应抽取到独立的 repository 文件中。
/// 此处为 GetAchievements UseCase 依赖的抽象接口。
abstract class AchievementRepository {
  /// 获取所有成就列表
  Future<List<AchievementEntity>> getAllAchievements();

  /// 根据分类获取成就列表
  Future<List<AchievementEntity>> getAchievementsByCategory(
      AchievementCategory category);

  /// 获取已解锁的成就列表
  Future<List<AchievementEntity>> getUnlockedAchievements();

  /// 根据成就 ID 获取单个成就
  Future<AchievementEntity?> getAchievementById(String achievementId);
}

/// 获取成就列表 UseCase
///
/// 从数据存储中获取成就列表，支持按分类筛选。
/// 返回的成就列表按排序值（sortOrder）升序排列。
class GetAchievements {
  final AchievementRepository _repository;

  const GetAchievements(this._repository);

  /// 执行获取成就列表
  ///
  /// [category] 可选的分类筛选参数。
  /// - 为 null 时返回所有成就
  /// - 指定分类时仅返回该分类下的成就
  ///
  /// 返回按 sortOrder 升序排列的成就列表。
  Future<List<AchievementEntity>> call({AchievementCategory? category}) {
    if (category != null) {
      return _repository.getAchievementsByCategory(category);
    }
    return _repository.getAllAchievements();
  }

  /// 获取所有成就（便捷方法）
  Future<List<AchievementEntity>> getAll() => call();

  /// 获取已解锁的成就（便捷方法）
  Future<List<AchievementEntity>> getUnlocked() {
    return _repository.getUnlockedAchievements();
  }

  /// 根据成就 ID 获取单个成就（便捷方法）
  Future<AchievementEntity?> getById(String achievementId) {
    return _repository.getAchievementById(achievementId);
  }
}

/// GetAchievements UseCase 的 Riverpod Provider
///
/// 使用 @riverpod 注解自动生成 Provider 代码。
/// 运行 `dart run build_runner build` 生成对应的 .g.dart 文件。
@riverpod
GetAchievements getAchievements(Ref ref, AchievementRepository repository) {
  return GetAchievements(repository);
}
