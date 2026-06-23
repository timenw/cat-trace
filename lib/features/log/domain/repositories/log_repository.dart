import '../entities/log_entity.dart';

/// 日志仓库接口（抽象类）
///
/// 定义日志数据操作的契约，由基础设施层（data layer）提供具体实现。
/// Domain 层通过此接口与数据源交互，不依赖任何具体的数据存储实现。
///
/// 该接口遵循依赖倒置原则（Dependency Inversion Principle）：
/// - 高层模块（Domain）不依赖低层模块（Data）
/// - 两者都依赖抽象（本接口）
///
/// 实现类：[LogRepositoryImpl]（位于 data/repositories/ 目录）
abstract class LogRepository {
  /// 添加一条新日志
  ///
  /// [log] 要添加的日志实体。
  /// 返回新创建日志的 ID。
  /// 如果添加失败，抛出 [LogRepositoryException]。
  Future<int> addLog(LogEntity log);

  /// 根据猫咪 ID 获取日志列表
  ///
  /// [catId] 猫咪的唯一标识符。
  /// 返回按记录时间降序排列的日志列表。
  /// 如果获取失败，抛出 [LogRepositoryException]。
  Future<List<LogEntity>> getLogsByCatId(int catId);

  /// 根据日志 ID 获取单条日志详情
  ///
  /// [id] 日志的唯一标识符。
  /// 如果找不到对应 ID 的日志，返回 null。
  /// 如果获取失败，抛出 [LogRepositoryException]。
  Future<LogEntity?> getLogById(int id);

  /// 获取所有日志
  ///
  /// [limit] 限制返回数量，默认为 50。
  /// [offset] 偏移量，用于分页，默认为 0。
  /// 结果按记录时间降序排列。
  /// 如果获取失败，抛出 [LogRepositoryException]。
  Future<List<LogEntity>> getAllLogs({int? limit, int? offset});

  /// 获取日志总数
  ///
  /// [catId] 为指定猫咪 ID 时，仅统计该猫咪的日志数量；
  /// 为 null 时统计所有日志数量。
  /// 如果获取失败，抛出 [LogRepositoryException]。
  Future<int> getLogCount({int? catId});

  /// 更新日志
  ///
  /// 根据日志 ID 更新对应记录，返回是否更新成功。
  /// 如果找不到对应记录或更新失败，抛出 [LogRepositoryException]。
  Future<bool> updateLog(LogEntity log);

  /// 删除日志
  ///
  /// 根据日志 ID 执行物理删除。
  /// 如果找不到对应记录或删除失败，抛出 [LogRepositoryException]。
  /// 返回是否删除成功。
  Future<bool> deleteLog(int id);

  /// 删除指定猫咪的所有日志
  ///
  /// 当删除猫咪时，需要同时删除该猫咪的所有日志记录。
  /// 如果删除失败，抛出 [LogRepositoryException]。
  Future<void> deleteLogsByCatId(int catId);
}

/// 仓库层异常
///
/// 当仓库操作失败时抛出此异常。
/// 该异常封装了底层（数据源层）的错误信息，
/// 为上层提供统一的错误处理接口。
class LogRepositoryException implements Exception {
  /// 异常描述信息
  final String message;

  /// 构造函数
  const LogRepositoryException(this.message);

  @override
  String toString() => 'LogRepositoryException: $message';
}
