import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/log_entity.dart';

part 'add_log.g.dart';

/// 日志仓库接口（前向引用）
///
/// 实际项目中应抽取到独立的 repository 文件中。
/// 此处为 AddLog UseCase 依赖的抽象接口。
abstract class LogRepository {
  Future<int> addLog(LogEntity log);
  Future<List<LogEntity>> getLogsByCatId(int catId);
}

/// 添加日志 UseCase
///
/// 将一条新的日志记录添加到数据存储中。
class AddLog {
  final LogRepository _repository;

  const AddLog(this._repository);

  /// 执行添加日志
  ///
  /// [log] 要添加的日志实体。
  /// 返回新创建日志的 ID。
  Future<int> call(LogEntity log) {
    return _repository.addLog(log);
  }
}

/// AddLog UseCase 的 Riverpod Provider
@riverpod
AddLog addLog(Ref ref, LogRepository repository) {
  return AddLog(repository);
}
