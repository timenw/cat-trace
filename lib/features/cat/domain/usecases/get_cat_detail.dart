import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/cat_entity.dart';
import '../repositories/cat_repository.dart';

part 'get_cat_detail.g.dart';

/// 获取猫咪详情 UseCase
///
/// 根据猫咪 ID 获取单只猫咪的完整信息。
class GetCatDetail {
  final CatRepository _repository;

  const GetCatDetail(this._repository);

  /// 执行获取猫咪详情
  ///
  /// [id] 猫咪的唯一标识符。
  /// 如果找不到对应猫咪，返回 null。
  Future<CatEntity?> call(int id) {
    return _repository.getCatById(id);
  }
}

/// GetCatDetail UseCase 的 Riverpod Provider
@riverpod
GetCatDetail getCatDetail(GetCatDetailRef ref, CatRepository repository) {
  return GetCatDetail(repository);
}
