import 'datasources/cat_local_datasource.dart';
import '../../domain/entities/cat_entity.dart';
import '../../domain/repositories/cat_repository.dart';

/// 猫咪仓库实现 — 基于 [CatLocalDataSource]
///
/// 该实现通过 [CatLocalDataSource] 与 Isar 数据库交互，
/// 将数据源层的异常转换为仓库层的领域异常。
///
/// 架构分层：
/// - Domain 层（CatRepository 接口）← 本文件（CatRepositoryImpl）
/// - Data 层（CatLocalDataSource）← 封装 Isar 操作
/// - Schema 层（CatSchema）← Isar 数据库模型
///
/// 所有数据操作异常都会被捕获并转换为 [CatRepositoryException]，
/// 以便上层（UseCase / Presentation）统一处理错误。
class CatRepositoryImpl implements CatRepository {
  /// 猫咪本地数据源
  final CatLocalDataSource _datasource;

  /// 构造函数，注入本地数据源实例
  CatRepositoryImpl(this._datasource);

  @override
  Future<List<CatEntity>> getAllCats({bool includeDeleted = false}) async {
    try {
      return await _datasource.getAllCats(includeDeleted: includeDeleted);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('获取猫咪列表失败: $e');
    }
  }

  @override
  Future<CatEntity?> getCatById(int id) async {
    try {
      return await _datasource.getCatById(id);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('获取猫咪详情失败 (id=$id): $e');
    }
  }

  @override
  Future<List<CatEntity>> searchCats(String query) async {
    try {
      return await _datasource.searchCats(query);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('搜索猫咪失败: $e');
    }
  }

  @override
  Future<int> getCatCount({bool includeDeleted = false}) async {
    try {
      return await _datasource.getCatCount(includeDeleted: includeDeleted);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('获取猫咪总数失败: $e');
    }
  }

  @override
  Future<int> addCat(CatEntity cat) async {
    try {
      return await _datasource.addCat(cat);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('添加猫咪失败: $e');
    }
  }

  @override
  Future<bool> updateCat(CatEntity cat) async {
    try {
      return await _datasource.updateCat(cat);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('更新猫咪失败: $e');
    }
  }

  @override
  Future<bool> deleteCat(int id, {bool permanent = false}) async {
    try {
      return await _datasource.deleteCat(id, permanent: permanent);
    } catch (e) {
      if (e is CatRepositoryException) rethrow;
      throw CatRepositoryException('删除猫咪失败: $e');
    }
  }
}

/// 仓库层异常
///
/// 当仓库操作失败时抛出此异常。
/// 该异常封装了底层（数据源层）的错误信息，
/// 为上层提供统一的错误处理接口。
class CatRepositoryException implements Exception {
  /// 异常描述信息
  final String message;

  /// 构造函数
  const CatRepositoryException(this.message);

  @override
  String toString() => 'CatRepositoryException: $message';
}
