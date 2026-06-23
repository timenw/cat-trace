import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cat_entity.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../data/repositories/cat_repository_impl.dart';

// ====== 仓库 Provider ======

/// 猫咪仓库 Provider
///
/// 提供 CatRepository 的单例实例，供所有 Cat 相关 Provider 使用。
/// 在实际项目中，此 Provider 应在基础设施层或通过依赖注入配置。
final catRepositoryProvider = Provider<CatRepository>((ref) {
  return CatRepositoryImpl(IsarDatabase.instance);
});

// ====== 猫咪列表 Provider ======

/// 猫咪列表 Provider
///
/// 获取所有猫咪列表，按最近观察时间降序排列。
/// 自动缓存数据，调用 `ref.invalidate(catsProvider)` 可刷新。
final catsProvider = FutureProvider<List<CatEntity>>((ref) async {
  final repository = ref.watch(catRepositoryProvider);
  return repository.getAllCats();
});

// ====== 猫咪详情 Provider ======

/// 猫咪详情 Provider（Family）
///
/// 根据猫咪 ID 获取单只猫咪的详细信息。
/// 使用 .family 修饰符支持参数化 Provider。
final catDetailProvider =
    FutureProvider.family<CatEntity?, int>((ref, catId) async {
  final repository = ref.watch(catRepositoryProvider);
  return repository.getCatById(catId);
});

// ====== 猫咪数量 Provider ======

/// 猫咪总数 Provider
///
/// 用于首页统计卡片显示猫咪总数。
final catCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(catRepositoryProvider);
  return repository.getCatCount();
});

// ====== 搜索 Provider ======

/// 搜索关键词 StateProvider
final catSearchQueryProvider = StateProvider<String>((ref) => '');

/// 筛选品种 StateProvider
final catFilterBreedProvider = StateProvider<String?>((ref) => null);

/// 筛选 TNR 状态 StateProvider
final catFilterTnrProvider = StateProvider<String?>((ref) => null);

/// 搜索结果 Provider
///
/// 根据搜索关键词和筛选条件返回过滤后的猫咪列表。
final catSearchResultsProvider = FutureProvider<List<CatEntity>>((ref) async {
  final repository = ref.watch(catRepositoryProvider);
  final query = ref.watch(catSearchQueryProvider);

  if (query.isEmpty) {
    return ref.watch(catsProvider.future);
  }

  return repository.searchCats(query);
});

// ====== 添加猫咪 Provider ======

/// 添加猫咪的异步操作 Provider
///
/// 返回一个可调用函数，传入 CatEntity 执行添加操作。
final addCatProvider = Provider<Future<int> Function(CatEntity)>((ref) {
  final repository = ref.watch(catRepositoryProvider);
  return (cat) => repository.addCat(cat);
});

// ====== 更新猫咪 Provider ======

/// 更新猫咪的异步操作 Provider
///
/// 返回一个可调用函数，传入 CatEntity 执行更新操作。
final updateCatProvider = Provider<Future<bool> Function(CatEntity)>((ref) {
  final repository = ref.watch(catRepositoryProvider);
  return (cat) => repository.updateCat(cat);
});

// ====== 删除猫咪 Provider ======

/// 删除猫咪的异步操作 Provider
///
/// 返回一个可调用函数，传入猫咪 ID 执行删除操作。
final deleteCatProvider = Provider<Future<bool> Function(int)>((ref) {
  final repository = ref.watch(catRepositoryProvider);
  return (id) => repository.deleteCat(id);
});
