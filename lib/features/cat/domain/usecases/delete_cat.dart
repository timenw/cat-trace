import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/cat_repository.dart';

part 'delete_cat.g.dart';

/// 删除猫咪 UseCase
///
/// 删除指定 ID 的猫咪记录，默认执行软删除。
class DeleteCat {
  final CatRepository _repository;

  const DeleteCat(this._repository);

  /// 执行删除猫咪
  ///
  /// [id] 要删除的猫咪 ID。
  /// [permanent] 是否永久删除（物理删除），默认为 false（软删除）。
  /// 返回是否删除成功。
  Future<bool> call(int id, {bool permanent = false}) {
    return _repository.deleteCat(id, permanent: permanent);
  }
}

/// DeleteCat UseCase 的 Riverpod Provider
@riverpod
DeleteCat deleteCat(Ref ref, CatRepository repository) {
  return DeleteCat(repository);
}
