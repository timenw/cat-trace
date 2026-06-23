import 'package:flutter/material.dart';

/// 通用 AppBar 组件
/// 提供统一的导航栏样式，支持标题、返回按钮、操作按钮等常用功能
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题文本
  final String title;

  /// 标题 Widget（优先级高于 title）
  final Widget? titleWidget;

  /// 左侧前置组件（默认为返回按钮）
  final Widget? leading;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 右侧操作按钮列表
  final List<Widget>? actions;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色（标题和图标颜色）
  final Color? foregroundColor;

  /// 底部阴影高度
  final double elevation;

  /// 是否居中标题
  final bool centerTitle;

  /// 底部组件（如 TabBar）
  final PreferredSizeWidget? bottom;

  /// 自定义高度
  final double? toolbarHeight;

  /// 返回按钮点击回调（默认行为为 Navigator.pop）
  final VoidCallback? onBackPressed;

  /// 标题样式
  final TextStyle? titleTextStyle;

  const CommonAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.5,
    this.centerTitle = true,
    this.bottom,
    this.toolbarHeight,
    this.onBackPressed,
    this.titleTextStyle,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onSurface;

    return AppBar(
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: effectiveForegroundColor,
                    size: 20,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: titleWidget ??
          Text(
            title,
            style: titleTextStyle ??
                TextStyle(
                  color: effectiveForegroundColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      actions: actions,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
    );
  }
}

/// 带搜索功能的 AppBar
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// 搜索框提示文字
  final String hintText;

  /// 搜索回调
  final ValueChanged<String> onSearch;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 初始搜索文本
  final String? initialText;

  /// 背景色
  final Color? backgroundColor;

  const SearchAppBar({
    super.key,
    this.hintText = '搜索猫咪...',
    required this.onSearch,
    this.onCancel,
    this.initialText,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late final TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _isSearching = widget.initialText?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _controller,
        autofocus: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                    setState(() => _isSearching = false);
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _isSearching = value.isNotEmpty);
          widget.onSearch(value);
        },
      ),
      actions: [
        if (_isSearching)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('取消'),
          ),
      ],
    );
  }
}
