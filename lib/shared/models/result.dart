/// 结果封装类
/// 统一处理操作的成功与失败结果，提供函数式的处理方式。
/// [T] 成功时返回的数据类型
class Result<T> {
  /// 操作是否成功
  final bool isSuccess;

  /// 成功时的数据
  final T? data;

  /// 失败时的错误消息
  final String? error;

  /// 失败时的异常对象
  final Object? exception;

  const Result._({
    required this.isSuccess,
    this.data,
    this.error,
    this.exception,
  });

  /// 创建一个成功的结果
  factory Result.success([T? data]) {
    return Result<T>._(isSuccess: true, data: data);
  }

  /// 创建一个失败的结果
  factory Result.failure({
    String? error,
    Object? exception,
  }) {
    return Result<T>._(
      isSuccess: false,
      error: error,
      exception: exception,
    );
  }

  /// 折叠操作：根据成功或失败状态分别处理
  /// [onSuccess] 成功时的回调，接收数据
  /// [onFailure] 失败时的回调，接收错误消息
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String? error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error);
    }
  }

  /// 简化版 fold，仅处理成功和失败两种情况
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error ?? '未知错误');
    }
  }

  /// 链式操作：如果成功，对数据应用 [transform] 并返回新结果
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Result.success(transform(data as T));
      } catch (e) {
        return Result.failure(error: '映射失败: $e', exception: e);
      }
    } else {
      return Result.failure(error: error, exception: exception);
    }
  }

  /// 扁平映射：如果成功，对数据应用 [transform]（其本身返回 Result）
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (isSuccess) {
      try {
        return transform(data as T);
      } catch (e) {
        return Result.failure(error: '扁平映射失败: $e', exception: e);
      }
    } else {
      return Result.failure(error: error, exception: exception);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.failure(error: $error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        other.data == data &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(isSuccess, data, error);
}
