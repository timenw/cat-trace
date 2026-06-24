import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/log_entity.dart';

part 'get_logs_by_cat.g.dart';

/// 日志仓库接口（前向引用）
///
/// 实际项目中应抽取到独立的 repository 文件中。
/// 此处为 GetLogsByCat UseCase 依赖的抽象接口。
abstract class LogRepository {
  Future<int> addLog(LogEntity log);
  Future<List<LogEntity>> getLogsByCatId(int catId);
}

/// 获取猫咪日志列表 UseCase
///
/// 根据猫咪 ID 获取与该猫咪相关的所有日志记录。
class GetLogsByCat {
  final LogRepository _repository;

  const GetLogsByCat(this._repository);

  /// 执行获取猫咪日志列表
  ///
  /// [catId] 猫咪的唯一标识符。
  /// 返回按记录时间降序排列的日志列表。
  Future<List<LogEntity>> call(int catId) {
    return _repository.getLogsByCatId(catId);
  }
}

/// GetLogsByCat UseCase 的 Riverpod Provider
@riverpod
GetLogsByCat getLogsByCat(Ref ref, LogRepository repository) {
  return GetLogsByCat(repository);
}
