import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/cat_entity.dart';
import '../repositories/cat_repository.dart';

part 'add_cat.g.dart';

/// 添加猫咪 UseCase
///
/// 将一只新猫咪添加到数据存储中。
class AddCat {
  final CatRepository _repository;

  const AddCat(this._repository);

  /// 执行添加猫咪
  ///
  /// [cat] 要添加的猫咪实体。
  /// 返回新创建猫咪的 ID。
  Future<int> call(CatEntity cat) {
    return _repository.addCat(cat);
  }
}

/// AddCat UseCase 的 Riverpod Provider
@riverpod
AddCat addCat(Ref ref, CatRepository repository) {
  return AddCat(repository);
}
