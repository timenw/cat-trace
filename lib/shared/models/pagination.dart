/// 分页模型
/// 封装分页查询所需的参数和结果，便于统一处理分页数据。
class Pagination<T> {
  /// 当前页码（从 1 开始）
  final int page;

  /// 每页数据条数
  final int pageSize;

  /// 数据总条数
  final int total;

  /// 当前页的数据列表
  final List<T> data;

  /// 构造分页对象
  /// [page] 当前页码（从 1 开始）
  /// [pageSize] 每页显示条数
  /// [total] 数据总条数
  /// [data] 当前页数据列表
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    this.data = const [],
  });

  /// 是否有下一页数据
  bool hasMore() {
    return page * pageSize < total;
  }

  /// 当前页是否是第一页
  bool get isFirstPage => page <= 1;

  /// 当前页是否是最后一页
  bool get isLastPage => !hasMore();

  /// 总页数
  int get totalPages {
    if (total == 0) return 0;
    return (total / pageSize).ceil();
  }

  /// 下一页页码（如果没有下一页则返回当前页码）
  int get nextPage => hasMore() ? page + 1 : page;

  /// 上一页页码（如果没有上一页则返回当前页码）
  int get previousPage => (page > 1) ? page - 1 : page;

  /// 创建一个带有新数据的分页对象，分页参数保持不变
  Pagination<T> copyWith({
    int? page,
    int? pageSize,
    int? total,
    List<T>? data,
  }) {
    return Pagination<T>(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'Pagination(page: $page, pageSize: $pageSize, total: $total, dataLength: ${data.length}, hasMore: ${hasMore()})';
  }
}
