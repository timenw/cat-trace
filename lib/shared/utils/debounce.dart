import 'dart:async';

/// 防抖工具类
/// 在 [delay] 时间内如果再次触发，则重新计时，只在最后一次触发后执行回调。
/// 适用于搜索输入、按钮防重复点击等场景。
class Debounce {
  /// 延迟时间（毫秒）
  final int delay;

  /// 内部计时器
  Timer? _timer;

  /// 防抖构造函数
  /// [delay] 防抖延迟时间（毫秒），默认为 500ms
  Debounce({this.delay = 500});

  /// 执行防抖操作
  /// [callback] 延迟后要执行的回调函数
  /// 如果在延迟期间再次调用，之前的回调将被取消
  void run(VoidCallback callback) {
    // 取消之前的计时器
    _timer?.cancel();
    // 设置新的计时器
    _timer = Timer(Duration(milliseconds: delay), callback);
  }

  /// 立即执行回调，同时取消后续的防抖计时
  /// 适用于需要"立即响应 + 防抖"的场景
  void flush(VoidCallback callback) {
    _timer?.cancel();
    _timer = null;
    callback();
  }

  /// 取消当前防抖计时器
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 检查是否有正在等待执行的回调
  bool get isActive => _timer?.isActive ?? false;
}

/// VoidCallback 类型定义
typedef VoidCallback = void Function();
