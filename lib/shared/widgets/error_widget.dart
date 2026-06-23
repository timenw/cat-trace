import 'package:flutter/material.dart';

/// 错误状态组件
/// 展示错误信息，支持重试操作和多种预设错误类型
class ErrorStateWidget extends StatelessWidget {
  /// 错误图标
  final IconData icon;

  /// 错误标题
  final String title;

  /// 错误描述
  final String? message;

  /// 重试按钮文本
  final String? retryText;

  /// 重试回调
  final VoidCallback? onRetry;

  /// 自定义图标组件
  final Widget? iconWidget;

  /// 自定义内容
  final Widget? content;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 描述文本样式
  final TextStyle? messageStyle;

  /// 整体内边距
  final EdgeInsetsGeometry padding;

  const ErrorStateWidget({
    super.key,
    this.icon = Icons.error_outline_rounded,
    required this.title,
    this.message,
    this.retryText = '重试',
    this.onRetry,
    this.iconWidget,
    this.content,
    this.iconSize = 72,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.padding = const EdgeInsets.all(32),
  });

  /// 预设：网络错误
  const ErrorStateWidget.network({
    super.key,
    this.message = '请检查网络连接后重试',
    this.retryText = '重新加载',
    this.onRetry,
    this.content,
    this.padding = const EdgeInsets.all(32),
  })  : icon = Icons.wifi_off_rounded,
        iconSize = 72,
        iconColor = null,
        title = '网络连接失败',
        titleStyle = null,
        messageStyle = null,
        iconWidget = null;

  /// 预设：服务器错误
  const ErrorStateWidget.server({
    super.key,
    this.message = '服务器暂时不可用，请稍后再试',
    this.retryText = '重试',
    this.onRetry,
    this.content,
    this.padding = const EdgeInsets.all(32),
  })  : icon = Icons.cloud_off_rounded,
        iconSize = 72,
        iconColor = null,
        title = '服务器开小差了',
        titleStyle = null,
        messageStyle = null,
        iconWidget = null;

  /// 预设：请求超时
  const ErrorStateWidget.timeout({
    super.key,
    this.message = '请求超时，请检查网络后重试',
    this.retryText = '重试',
    this.onRetry,
    this.content,
    this.padding = const EdgeInsets.all(32),
  })  : icon = Icons.access_time_rounded,
        iconSize = 72,
        iconColor = null,
        title = '请求超时',
        titleStyle = null,
        messageStyle = null,
        iconWidget = null;

  /// 预设：未知错误
  const ErrorStateWidget.unknown({
    super.key,
    this.message = '发生了未知错误，请稍后重试',
    this.retryText = '重试',
    this.onRetry,
    this.content,
    this.padding = const EdgeInsets.all(32),
  })  : icon = Icons.help_outline_rounded,
        iconSize = 72,
        iconColor = null,
    title = '出错了',
        titleStyle = null,
        messageStyle = null,
        iconWidget = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.error.withOpacity(0.6);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            iconWidget ??
                Icon(
                  icon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),

            const SizedBox(height: 20),

            // 标题
            Text(
              title,
              style: titleStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),

            // 描述信息
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: messageStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // 自定义内容
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            // 重试按钮
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 内联错误提示条
/// 用于表单验证等轻量级错误展示
class InlineError extends StatelessWidget {
  /// 错误文本
  final String message;

  /// 图标
  final IconData icon;

  /// 颜色
  final Color? color;

  const InlineError({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: effectiveColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: effectiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 错误边界组件
/// 捕获子组件树中的错误并展示友好的错误页面
class ErrorBoundary extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 错误时展示的组件
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// 错误回调
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // 设置 Flutter 错误回调
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
      widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return ErrorStateWidget.unknown(
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
    return widget.child;
  }
}
