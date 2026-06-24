import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/cat_entity.dart';
import '../repositories/cat_repository.dart';

part 'update_cat.g.dart';

/// 更新猫咪信息 UseCase
///
/// 更新已存在的猫咪记录。
class UpdateCat {
  final CatRepository _repository;

  const UpdateCat(this._repository);

  /// 执行更新猫咪
  ///
  /// [cat] 包含更新信息的猫咪实体（必须包含有效 ID）。
  /// 返回是否更新成功。
  Future<bool> call(CatEntity cat) {
    return _repository.updateCat(cat);
  }
}

/// UpdateCat UseCase 的 Riverpod Provider
@riverpod
UpdateCat updateCat(Ref ref, CatRepository repository) {
  return UpdateCat(repository);
}
