import '../entities/cat_entity.dart';

/// 猫咪仓库接口（抽象类）
///
/// 定义猫咪数据操作的契约，由基础设施层（data layer）提供具体实现。
/// Domain 层通过此接口与数据源交互，不依赖任何具体的数据存储实现。
abstract class CatRepository {
  /// 获取所有猫咪列表
  ///
  /// 返回按最近观察时间降序排列的猫咪列表。
  /// 可选择是否包含已软删除的记录。
  Future<List<CatEntity>> getAllCats({bool includeDeleted = false});

  /// 根据 ID 获取单只猫咪详情
  ///
  /// 如果找不到对应 ID 的猫咪，返回 null。
  Future<CatEntity?> getCatById(int id);

  /// 添加一只新猫咪
  ///
  /// 返回新创建猫咪的 ID。
  Future<int> addCat(CatEntity cat);

  /// 更新猫咪信息
  ///
  /// 根据猫咪 ID 更新对应记录，返回是否更新成功。
  Future<bool> updateCat(CatEntity cat);

  /// 删除猫咪
  ///
  /// 默认执行软删除（标记 isDeleted = true），
  /// 设置 [permanent] 为 true 时执行物理删除。
  /// 返回是否删除成功。
  Future<bool> deleteCat(int id, {bool permanent = false});

  /// 搜索猫咪
  ///
  /// 支持按昵称、品种、毛色、标签等关键词模糊搜索。
  /// 返回匹配的猫咪列表。
  Future<List<CatEntity>> searchCats(String query);

  /// 获取猫咪总数
  ///
  /// 可选择是否包含已软删除的记录。
  Future<int> getCatCount({bool includeDeleted = false});
}
