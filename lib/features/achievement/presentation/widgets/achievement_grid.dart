import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/achievement_entity.dart';
import 'achievement_card.dart';

/// 成就网格组件
///
/// 以网格布局展示成就列表，支持以下功能：
/// - 响应式列数（根据屏幕宽度自动调整）
/// - 按分类筛选
/// - 显示空状态
/// - 点击成就卡片回调
///
/// 使用示例：
/// ```dart
/// AchievementGrid(
///   achievements: achievementList,
///   onAchievementTap: (achievement) => showDetail(achievement),
/// )
/// ```
class AchievementGrid extends StatelessWidget {
  /// 成就列表
  final List<AchievementEntity> achievements;

  /// 成就卡片点击回调
  final ValueChanged<AchievementEntity>? onAchievementTap;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态提示文本
  final String? emptyText;

  /// 空状态副标题
  final String? emptySubtitle;

  /// 自定义列数（为 null 时自动计算）
  final int? crossAxisCount;

  /// 子项宽高比
  final double childAspectRatio;

  const AchievementGrid({
    super.key,
    required this.achievements,
    this.onAchievementTap,
    this.isLoading = false,
    this.emptyText,
    this.emptySubtitle,
    this.crossAxisCount,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // 加载状态
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 空状态
    if (achievements.isEmpty) {
      return _buildEmptyState();
    }

    // 网格内容
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount ?? _calculateCrossAxisCount(context),
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          achievement: achievement,
          compact: true,
          onTap: onAchievementTap != null
              ? () => onAchievementTap!(achievement)
              : null,
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightTextHint.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 40,
                color: AppColors.lightTextHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyText ?? '暂无成就',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
              ),
            ),
            if (emptySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightTextHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据屏幕宽度计算列数
  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 3;
  }
}

/// 带分类筛选的成就网格组件
///
/// 在 [AchievementGrid] 基础上增加分类筛选 TabBar，
/// 用户可以按分类查看不同类型的成就。
class AchievementGridWithFilter extends StatefulWidget {
  /// 成就列表
  final List<AchievementEntity> achievements;

  /// 成就卡片点击回调
  final ValueChanged<AchievementEntity>? onAchievementTap;

  /// 是否正在加载
  final bool isLoading;

  const AchievementGridWithFilter({
    super.key,
    required this.achievements,
    this.onAchievementTap,
    this.isLoading = false,
  });

  @override
  State<AchievementGridWithFilter> createState() =>
      _AchievementGridWithFilterState();
}

class _AchievementGridWithFilterState
    extends State<AchievementGridWithFilter>
    with SingleTickerProviderStateMixin {
  /// 分类 TabController
  late TabController _tabController;

  /// 当前选中的分类（null 表示全部）
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // +1 是因为第一个 Tab 是"全部"
    _tabController = TabController(
      length: AchievementCategory.values.length + 1,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = _tabController.index == 0
              ? null
              : AchievementCategory.values[_tabController.index - 1];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据选中分类筛选成就
    final filteredAchievements = _selectedCategory == null
        ? widget.achievements
        : widget.achievements
            .where((a) => a.category == _selectedCategory)
            .toList();

    return Column(
      children: [
        // 分类筛选 TabBar
        _buildCategoryTabs(),
        const SizedBox(height: 8),
        // 成就网格
        Expanded(
          child: AchievementGrid(
            achievements: filteredAchievements,
            onAchievementTap: widget.onAchievementTap,
            isLoading: widget.isLoading,
            emptyText: _selectedCategory != null
                ? '${_getCategoryDisplayName(_selectedCategory!)}分类暂无成就'
                : '暂无成就',
            emptySubtitle: '收集更多猫咪来解锁成就吧！',
          ),
        ),
      ],
    );
  }

  /// 构建分类 TabBar
  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightTextHint,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          // "全部" Tab
          const Tab(text: '全部'),
          // 各分类 Tab
          ...AchievementCategory.values.map(
            (category) => Tab(text: _getCategoryDisplayName(category)),
          ),
        ],
      ),
    );
  }

  /// 获取分类的中文显示名称
  String _getCategoryDisplayName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.collection:
        return '收集';
      case AchievementCategory.log:
        return '记录';
      case AchievementCategory.tnr:
        return 'TNR';
      case AchievementCategory.special:
        return '特殊';
    }
  }
}
