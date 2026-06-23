import 'package:flutter/material.dart';

/// 加载动画组件
/// 提供多种样式的加载指示器，适用于不同场景
class LoadingWidget extends StatelessWidget {
  /// 加载提示文本
  final String? message;

  /// 加载指示器大小
  final double size;

  /// 颜色
  final Color? color;

  /// 线条宽度（仅 CircularProgressIndicator 使用）
  final double strokeWidth;

  /// 文本样式
  final TextStyle? messageStyle;

  /// 间距
  final double spacing;

  /// 是否全屏显示
  final bool fullscreen;

  /// 背景色（仅 fullscreen 为 true 时有效）
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.messageStyle,
    this.spacing = 16,
    this.fullscreen = false,
    this.backgroundColor,
  });

  /// 小型行内加载指示器
  const LoadingWidget.inline({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  })  : message = null,
        messageStyle = null,
        spacing = 8,
        fullscreen = false,
        backgroundColor = null;

  /// 全屏加载遮罩
  const LoadingWidget.overlay({
    super.key,
    this.message = '加载中...',
    this.size = 48,
    this.color,
    this.strokeWidth = 3.5,
    this.messageStyle,
    this.spacing = 20,
    this.fullscreen = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 加载指示器
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),

        // 提示文本
        if (message != null) ...[
          SizedBox(height: spacing),
          Text(
            message!,
            style: messageStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullscreen) {
      return Container(
        color: backgroundColor ?? theme.colorScheme.surface.withOpacity(0.9),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// 猫咪主题加载动画
/// 使用猫咪脚印图案的趣味加载指示器
class CatPawLoading extends StatefulWidget {
  /// 提示文本
  final String? message;

  /// 大小
  final double size;

  /// 颜色
  final Color? color;

  const CatPawLoading({
    super.key,
    this.message,
    this.size = 60,
    this.color,
  });

  @override
  State<CatPawLoading> createState() => _CatPawLoadingState();
}

class _CatPawLoadingState extends State<CatPawLoading>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    // 创建 4 个动画控制器，模拟脚印依次出现的效果
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();

    // 依次启动动画
    _startSequentialAnimation();
  }

  void _startSequentialAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _controllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      for (final controller in _controllers) {
        controller.reset();
      }
      _startSequentialAnimation();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size * 2,
          height: widget.size * 2,
          child: Stack(
            children: [
              // 四个脚印位置
              _buildPaw(0, Offset(widget.size * 0.1, widget.size * 0.2), effectiveColor),
              _buildPaw(1, Offset(widget.size * 0.9, widget.size * 0.1), effectiveColor),
              _buildPaw(2, Offset(widget.size * 0.2, widget.size * 0.8), effectiveColor),
              _buildPaw(3, Offset(widget.size * 0.8, widget.size * 0.7), effectiveColor),
            ],
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaw(int index, Offset position, Color color) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Transform.scale(
            scale: _animations[index].value,
            child: Opacity(
              opacity: _animations[index].value,
              child: Icon(
                Icons.pets_rounded,
                size: widget.size * 0.4,
                color: color.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏加载组件
/// 用于列表项的占位加载效果
class SkeletonLoading extends StatefulWidget {
  /// 子组件（定义骨架形状）
  final Widget child;

  /// 是否启用闪烁动画
  final bool shimmer;

  const SkeletonLoading({
    super.key,
    required this.child,
    this.shimmer = true,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shimmer) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// 列表项骨架屏
class ListItemSkeleton extends StatelessWidget {
  /// 显示数量
  final int count;

  const ListItemSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return SkeletonLoading(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 圆形头像占位
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // 文本占位
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
