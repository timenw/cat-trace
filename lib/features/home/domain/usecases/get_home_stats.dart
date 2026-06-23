import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../cat/domain/repositories/cat_repository.dart';
import '../../../log/domain/repositories/log_repository.dart';

part 'get_home_stats.g.dart';

/// 首页统计数据模型
///
/// 封装首页所需的三类核心统计信息：
/// - 猫咪总数：用户已记录的所有猫咪数量
/// - 今日日志数：当天创建的日志记录总数
/// - 连续记录天数：用户连续记录日志的天数（打卡天数）
class HomeStats {
  /// 用户已记录的猫咪总数
  final int totalCats;

  /// 今日创建的日志记录总数
  final int todayLogs;

  /// 连续记录天数（打卡天数）
  final int streakDays;

  const HomeStats({
    required this.totalCats,
    required this.todayLogs,
    required this.streakDays,
  });

  /// 创建默认空统计（所有值均为 0）
  const HomeStats.empty()
      : totalCats = 0,
        todayLogs = 0,
        streakDays = 0;

  @override
  String toString() =>
      'HomeStats(totalCats: $totalCats, todayLogs: $todayLogs, streakDays: $streakDays)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeStats &&
          runtimeType == other.runtimeType &&
          totalCats == other.totalCats &&
          todayLogs == other.todayLogs &&
          streakDays == other.streakDays;

  @override
  int get hashCode =>
      totalCats.hashCode ^ todayLogs.hashCode ^ streakDays.hashCode;
}

/// 获取首页统计数据 UseCase
///
/// 聚合来自猫咪仓库和日志仓库的数据，计算首页所需的统计信息：
/// 1. 猫咪总数：从 CatRepository 获取
/// 2. 今日日志数：从 LogRepository 获取今日创建的日志数量
/// 3. 连续记录天数：根据日志记录计算用户连续打卡的天数
///
/// 该 UseCase 遵循单一职责原则，仅负责首页统计数据的聚合。
class GetHomeStats {
  final CatRepository _catRepository;
  final LogRepository _logRepository;

  const GetHomeStats(this._catRepository, this._logRepository);

  /// 执行获取首页统计数据
  ///
  /// 返回 [HomeStats] 实例，包含猫咪总数、今日日志数和连续记录天数。
  /// 如果获取过程中发生异常，将抛出相应的仓库异常。
  Future<HomeStats> call() async {
    // 并行获取猫咪总数和所有日志，提高性能
    final results = await Future.wait([
      _catRepository.getCatCount(),
      _logRepository.getAllLogs(),
    ]);

    final totalCats = results[0] as int;
    final allLogs = results[1] as List;

    // 计算今日日志数
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayLogs = allLogs.where((log) {
      final recordedAt = log.recordedAt as DateTime;
      return recordedAt.isAfter(todayStart) && recordedAt.isBefore(todayEnd);
    }).length;

    // 计算连续记录天数
    final streakDays = _calculateStreakDays(allLogs);

    return HomeStats(
      totalCats: totalCats,
      todayLogs: todayLogs,
      streakDays: streakDays,
    );
  }

  /// 计算连续记录天数
  ///
  /// 算法说明：
  /// 1. 提取所有日志的日期（去除时间部分）
  /// 2. 去重后按日期降序排列
  /// 3. 从今天开始往前检查连续的天数
  ///
  /// 如果今天没有记录，则从昨天开始计算。
  int _calculateStreakDays(List logs) {
    if (logs.isEmpty) return 0;

    // 提取所有不重复的日期
    final dateSet = <String>{};
    for (final log in logs) {
      final recordedAt = log.recordedAt as DateTime;
      final dateKey = '${recordedAt.year}-'
          '${recordedAt.month.toString().padLeft(2, '0')}-'
          '${recordedAt.day.toString().padLeft(2, '0')}';
      dateSet.add(dateKey);
    }

    // 将日期转换为 DateTime 列表并降序排列
    final sortedDates = dateSet
        .map((key) => DateTime.parse(key))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 确定起始日期：如果今天有记录则从今天开始，否则从昨天开始
    final latestDate = sortedDates.first;
    final daysFromToday = todayDate.difference(latestDate).inDays;

    // 如果最近记录距今超过 1 天，说明已经断签
    if (daysFromToday > 1) return 0;

    // 从最近记录日期开始往前计算连续天数
    int streak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i - 1].difference(sortedDates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

/// GetHomeStats UseCase 的 Riverpod Provider
///
/// 注入 CatRepository 和 LogRepository，创建 GetHomeStats 实例。
@riverpod
GetHomeStats getHomeStats(Ref ref, CatRepository catRepository,
    LogRepository logRepository) {
  return GetHomeStats(catRepository, logRepository);
}

/// 首页统计数据 Provider
///
/// 使用 FutureProvider 异步获取首页统计数据，
/// 支持自动缓存和手动刷新（通过 ref.invalidate）。
final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  // 注意：此 Provider 需要在 Widget 中通过覆盖方式注入仓库实例
  // 实际使用时，建议在 presentation 层通过 ScopedProvider 或
  // 在 Widget 中直接调用 GetHomeStats 实例
  throw UnimplementedError(
    'homeStatsProvider 需要注入 CatRepository 和 LogRepository。'
    '请在 Widget 中使用 getHomeStatsProvider(catRepo, logRepo) 获取实例后调用。',
  );
});
