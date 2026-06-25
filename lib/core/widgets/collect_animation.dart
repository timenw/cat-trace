import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 收集动画组件
/// 
/// 当用户收集新猫咪时显示庆祝动画
class CollectAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const CollectAnimation({super.key, this.onComplete});

  @override
  State<CollectAnimation> createState() => _CollectAnimationState();
}

class _CollectAnimationState extends State<CollectAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.forward().then((_) {
      if (widget.onComplete != null) widget.onComplete!();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 粒子效果
        ...List.generate(8, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = _controller.value * 100;
              return Transform.translate(
                offset: Offset(
                  offset * (i % 2 == 0 ? 1 : -1),
                  -offset,
                ),
                child: Opacity(
                  opacity: 1 - _controller.value,
                  child: const Text('🐱', style: TextStyle(fontSize: 24)),
                ),
              );
            },
          );
        }),
        // 主图标
        ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.2).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 50)),
            ),
          ),
        ),
      ],
    );
  }
}

/// 显示收集动画
Future<void> showCollectAnimation(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const AlertDialog(
      content: SizedBox(
        width: 200,
        height: 200,
        child: CollectAnimation(),
      ),
    ),
  );
}