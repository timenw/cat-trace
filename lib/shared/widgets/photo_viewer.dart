import 'package:flutter/material.dart';

/// 图片查看器组件
/// 支持缩放、拖拽、双击放大等交互功能
class PhotoViewer extends StatefulWidget {
  /// 图片 URL 列表
  final List<String> imageUrls;

  /// 初始显示的图片索引
  final int initialIndex;

  /// 是否显示页码指示器
  final bool showIndicator;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 背景色
  final Color backgroundColor;

  /// 占位图组件
  final Widget Function(BuildContext, String)? placeholderBuilder;

  /// 错误图组件
  final Widget Function(BuildContext, String, Object)? errorBuilder;

  const PhotoViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.showIndicator = true,
    this.showCloseButton = true,
    this.backgroundColor = Colors.black,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  /// 显示单张图片
  static Future<void> showSingle(
    BuildContext context, {
    required String imageUrl,
    Color backgroundColor = Colors.black,
  }) {
    return showDialog(
      context: context,
      barrierColor: backgroundColor,
      builder: (context) => PhotoViewer(
        imageUrls: [imageUrl],
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// 显示多张图片
  static Future<void> showMultiple(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    Color backgroundColor = Colors.black,
  }) {
    return showDialog(
      context: context,
      barrierColor: backgroundColor,
      builder: (context) => PhotoViewer(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() => _showAppBar = !_showAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          // 图片页面
          GestureDetector(
            onTap: _toggleAppBar,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _ZoomableImage(
                  imageUrl: widget.imageUrls[index],
                  placeholderBuilder: widget.placeholderBuilder,
                  errorBuilder: widget.errorBuilder,
                );
              },
            ),
          ),

          // 顶部栏
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showAppBar ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // 底部页码指示器
          if (widget.showIndicator && widget.imageUrls.length > 1)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _showAppBar ? 0 : -100,
              left: 0,
              right: 0,
              child: _buildIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          if (widget.showCloseButton)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          Expanded(
            child: Text(
              '${_currentIndex + 1} / ${widget.imageUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 占位，保持标题居中
          if (widget.showCloseButton)
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == _currentIndex ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == _currentIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

/// 可缩放图片组件
class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final Widget Function(BuildContext, String)? placeholderBuilder;
  final Widget Function(BuildContext, String, Object)? errorBuilder;

  const _ZoomableImage({
    required this.imageUrl,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController.addListener(() {
      if (_animation != null) {
        _transformController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// 双击放大/还原
  void _handleDoubleTap() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale = currentScale > 1.0 ? 1.0 : 2.0;

    final endMatrix = Matrix4.identity()
      ..scale(targetScale);

    _animation = Matrix4Tween(
      begin: _transformController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return widget.placeholderBuilder?.call(context, widget.imageUrl) ??
                  Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
            },
            errorBuilder: (context, error, stackTrace) {
              return widget.errorBuilder
                      ?.call(context, widget.imageUrl, error) ??
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '图片加载失败',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }
}

/// 猫咪图片卡片
/// 带点击放大预览功能的图片展示组件
class CatPhotoCard extends StatelessWidget {
  /// 图片 URL
  final String imageUrl;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角
  final double borderRadius;

  /// 是否可点击放大
  final bool tappable;

  /// 点击回调
  final VoidCallback? onTap;

  /// Hero 动画标签
  final String? heroTag;

  const CatPhotoCard({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.tappable = true,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height ?? 200,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height ?? 200,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              size: 32,
            ),
          );
        },
      ),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    if (tappable) {
      return GestureDetector(
        onTap: onTap ?? () => PhotoViewer.showSingle(context, imageUrl: imageUrl),
        child: image,
      );
    }

    return image;
  }
}
