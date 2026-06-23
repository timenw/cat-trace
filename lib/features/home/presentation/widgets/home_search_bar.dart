import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// 首页搜索栏组件
///
/// 提供猫咪搜索功能，支持：
/// - 按昵称、品种、毛色等关键词搜索
/// - 搜索历史记录（最多 5 条）
/// - 清除搜索内容
/// - 搜索建议提示
///
/// 该组件为受控组件，搜索逻辑由父组件通过 [onSearch] 回调处理。
class HomeSearchBar extends StatefulWidget {
  /// 搜索回调，传入搜索关键词
  final ValueChanged<String> onSearch;

  /// 搜索栏获得焦点时的回调（可选）
  final VoidCallback? onFocus;

  /// 搜索栏失去焦点时的回调（可选）
  final VoidCallback? onUnfocus;

  /// 初始搜索文本（可选）
  final String? initialValue;

  /// 是否自动获取焦点
  final bool autoFocus;

  /// 自定义提示文本
  final String? hintText;

  const HomeSearchBar({
    super.key,
    required this.onSearch,
    this.onFocus,
    this.onUnfocus,
    this.initialValue,
    this.autoFocus = false,
    this.hintText,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  /// 文本控制器
  late final TextEditingController _controller;

  /// 焦点节点
  late final FocusNode _focusNode;

  /// 是否显示清除按钮
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _showClear = widget.initialValue?.isNotEmpty ?? false;

    // 监听文本变化
    _controller.addListener(_onTextChanged);

    // 监听焦点变化
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 文本变化回调
  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClear) {
      setState(() => _showClear = hasText);
    }
  }

  /// 焦点变化回调
  void _onFocusChanged() {
    setState(() {}); // 重建以更新样式
    if (_focusNode.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onUnfocus?.call();
    }
  }

  /// 清除搜索内容
  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  /// 提交搜索
  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFocused = _focusNode.hasFocus;
    final hint = widget.hintText ?? AppStrings.searchHint;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isFocused ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: isFocused
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autoFocus,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          // 搜索图标（前缀）
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused
                ? AppColors.primary
                : theme.colorScheme.onSurface.withOpacity(0.4),
            size: 22,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),

          // 清除按钮（后缀）
          suffixIcon: _showClear
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                  tooltip: '清除搜索',
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),

          // 边框样式
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,

          // 内边距
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          // 填充色透明（外层 Container 已设置背景色）
          filled: false,
        ),
      ),
    );
  }
}
