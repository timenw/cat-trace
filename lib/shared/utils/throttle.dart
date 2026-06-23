import 'dart:async';

/// 节流工具类
/// 在 [duration] 时间间隔内最多执行一次回调。
/// 适用于滚动事件、缩放等需要限制频率的场景。
class Throttle {
  /// 节流时间间隔（毫秒）
  final int duration;

  /// 内部计时器
  Timer? _timer;

  /// 上一次执行的回调
  VoidCallback? _pendingCallback;

  /// 节流构造函数
  /// [duration] 节流时间间隔（毫秒），默认为 500ms
  Throttle({this.duration = 500});

  /// 执行节流操作
  /// [callback] 要执行的回调函数
  /// 如果在间隔期内多次调用，只在间隔结束后执行最后一次
  void run(VoidCallback callback) {
    _pendingCallback = callback;

    if (_timer == null || !_timer!.isActive) {
      // 立即执行第一次回调
      callback();
      // 启动计时器
      _timer = Timer(Duration(milliseconds: duration), _onTimerEnd);
    }
  }

  /// 计时器结束时的处理
  void _onTimerEnd() {
    _timer = null;
    // 如果有待执行的回调（说明期间有新的调用），立即执行
    if (_pendingCallback != null) {
      final callback = _pendingCallback!;
      _pendingCallback = null;
      callback();
      // 重新启动计时器
      _timer = Timer(Duration(milliseconds: duration), _onTimerEnd);
    }
  }

  /// 执行一次回调后等待冷却期结束再允许下次执行
  /// [callback] 要执行的回调
  /// 如果处于冷却期，则直接返回不执行
  void runLeading(VoidCallback callback) {
    if (_timer == null || !_timer!.isActive) {
      callback();
      _timer = Timer(Duration(milliseconds: duration), _onTimerEnd);
    } else {
      // 记录待回调，冷却结束后执行
      _pendingCallback = callback;
    }
  }

  /// 取消节流计时器和待执行的回调
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingCallback = null;
  }

  /// 检查是否处于冷却期（节流间隔中）
  bool get isActive => _timer?.isActive ?? false;
}

/// VoidCallback 类型定义
typedef VoidCallback = void Function();
