import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'rarity_badge.dart';

/// 庆祝动画组件
/// 当用户收集到新猫咪时展示的庆祝动画效果
class CelebrationAnimation extends StatefulWidget {
  /// 动画完成回调
  final VoidCallback? onComplete;

  /// 动画时长
  final Duration duration;

  /// 是否自动播放
  final bool autoPlay;

  /// 庆祝类型
  final CelebrationType type;

  const CelebrationAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2500),
    this.autoPlay = true,
    this.type = CelebrationType.confetti,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    if (widget.autoPlay) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _scaleController.forward();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 背景光晕
            _buildGlowEffect(),

            // 主内容缩放动画
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMainContent(),
            ),

            // 根据类型展示不同的庆祝效果
            ..._buildCelebrationEffects(),
          ],
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.amber.withOpacity(0.3 * _controller.value),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🎉',
          style: TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 12),
        const Text(
          '发现新猫咪！',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCelebrationEffects() {
    switch (widget.type) {
      case CelebrationType.confetti:
        return _buildConfetti();
      case CelebrationType.stars:
        return _buildStars();
      case CelebrationType.paws:
        return _buildPaws();
    }
  }

  /// 彩纸效果
  List<Widget> _buildConfetti() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return List.generate(20, (index) {
      final random = math.Random(index);
      final color = colors[random.nextInt(colors.length)];
      final angle = (index / 20) * 2 * math.pi;
      final distance = 80.0 + random.nextDouble() * 60;
      final size = 6.0 + random.nextDouble() * 6;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final dx = math.cos(angle) * distance * progress;
          final dy = math.sin(angle) * distance * progress + 30 * progress * progress;
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final rotation = progress * 4 * math.pi;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size * 0.6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// 星星效果
  List<Widget> _buildStars() {
    return List.generate(12, (index) {
      final angle = (index / 12) * 2 * math.pi;
      final distance = 100.0;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final dx = math.cos(angle) * distance * progress;
          final dy = math.sin(angle) * distance * progress;
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final scale = math.sin(progress * math.pi);

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: const Text(
                  '⭐',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// 猫爪效果
  List<Widget> _buildPaws() {
    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * math.pi;
      final distance = 90.0;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final dx = math.cos(angle) * distance * progress;
          final dy = math.sin(angle) * distance * progress;
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final scale = math.sin(progress * math.pi);

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: const Text(
                  '🐾',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

/// 庆祝动画类型
enum CelebrationType {
  /// 彩纸
  confetti,

  /// 星星
  stars,

  /// 猫爪
  paws,
}

/// 稀有度庆祝动画
/// 根据猫咪稀有度展示不同强度的庆祝效果
class RarityCelebration extends StatefulWidget {
  /// 猫咪稀有度
  final Rarity rarity;

  /// 猫咪名称
  final String catName;

  /// 猫咪图片 URL
  final String? imageUrl;

  /// 关闭回调
  final VoidCallback? onClose;

  const RarityCelebration({
    super.key,
    required this.rarity,
    required this.catName,
    this.imageUrl,
    this.onClose,
  });

  @override
  State<RarityCelebration> createState() => _RarityCelebrationState();
}

class _RarityCelebrationState extends State<RarityCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _particleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    _mainController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// 根据稀有度获取庆祝类型
  CelebrationType get _celebrationType {
    switch (widget.rarity) {
      case Rarity.common:
        return CelebrationType.paws;
      case Rarity.uncommon:
        return CelebrationType.stars;
      case Rarity.rare:
        return CelebrationType.stars;
      case Rarity.epic:
      case Rarity.legendary:
        return CelebrationType.confetti;
    }
  }

  /// 根据稀有度获取背景颜色
  Color get _rarityColor => RarityBadge.getRarityColor(widget.rarity);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: widget.onClose,
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 庆祝粒子效果
          SizedBox(
            width: 300,
            height: 200,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    color: _rarityColor,
                    particleCount: RarityBadge.getRarityLevel(widget.rarity) * 10,
                  ),
                );
              },
            ),
          ),

          // 猫咪卡片
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _rarityColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 稀有度徽章
                RarityBadge.withStars(rarity: widget.rarity),
                const SizedBox(height: 16),

                // 猫咪名称
                Text(
                  widget.catName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 提示文字
                Text(
                  '已添加到你的图鉴',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // 确认按钮
                FilledButton(
                  onPressed: widget.onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: _rarityColor,
                    minimumSize: const Size(160, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '太棒了！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 粒子效果绘制器
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int particleCount;

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final distance = progress * speed * size.width * 0.6;
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = size.height / 2 + math.sin(angle) * distance;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final particleSize = (3.0 + random.nextDouble() * 4.0) * (1.0 - progress * 0.5);

      paint.color = color.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
