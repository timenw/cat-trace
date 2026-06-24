import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/cat_entity.dart';
import '../repositories/cat_repository.dart';

part 'get_cats.g.dart';

/// 获取所有猫咪列表 UseCase
///
/// 从仓库中获取所有猫咪，按最近观察时间降序排列。
class GetCats {
  final CatRepository _repository;

  const GetCats(this._repository);

  /// 执行获取所有猫咪
  ///
  /// [includeDeleted] 是否包含已软删除的记录，默认为 false。
  Future<List<CatEntity>> call({bool includeDeleted = false}) {
    return _repository.getAllCats(includeDeleted: includeDeleted);
  }
}

/// GetCats UseCase 的 Riverpod Provider
@riverpod
GetCats getCats(Ref ref, CatRepository repository) {
  return GetCats(repository);
}
