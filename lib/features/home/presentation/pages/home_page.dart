import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../cat/domain/entities/cat_entity.dart';
import '../../cat/presentation/pages/cat_list_page.dart';
import '../../cat/presentation/providers/cat_providers.dart';
import '../../calendar/presentation/pages/calendar_page.dart';
import '../../achievement/presentation/pages/achievement_page.dart';
import '../../settings/presentation/pages/settings_page.dart';
import '../domain/usecases/get_home_stats.dart';
import '../presentation/widgets/collection_stats.dart';
import '../presentation/widgets/home_search_bar.dart';
import '../presentation/widgets/quick_actions.dart';
import '../presentation/widgets/recent_cats.dart';

/// 首页 — 包含底部导航栏
///
/// 猫迹 App 的主页面，采用 Tab 式导航结构，包含五个 Tab：
/// 1. 首页：统计概览、快速操作、最近查看
/// 2. 图鉴：猫咪列表
/// 3. 日历：记录时间线
/// 4. 成就：徽章和收集进度
/// 5. 设置：应用设置
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  /// 当前选中的 Tab 索引
  int _currentIndex = 0;

  /// 搜索关键词
  String _searchQuery = '';

  /// 各 Tab 页面
  final _pages = const [
    _HomeTab(),
    _CatListTab(),
    _CalendarTab(),
    _AchievementTab(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: '图鉴',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: '成就',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

/// 首页 Tab
///
/// 展示用户的收集统计、搜索栏、快速操作和最近查看的猫咪。
/// 使用 Riverpod 的 FutureProvider 异步加载数据。
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 异步获取猫咪列表数据
    final catsAsync = ref.watch(catsProvider);
    // 异步获取猫咪总数
    final catCountAsync = ref.watch(catCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== 搜索栏 ======
            HomeSearchBar(
              onSearch: (query) {
                // TODO: 实现搜索逻辑，跳转到搜索结果页面
                debugPrint('搜索: $query');
              },
            ),
            const SizedBox(height: 20),

            // ====== 收集统计卡片 ======
            // 使用 catCountAsync 获取猫咪总数，其他统计暂时使用默认值
            catCountAsync.when(
              data: (catCount) => CollectionStats(
                totalCats: catCount,
                todayLogs: 0, // TODO: 从日志数据获取
                streakDays: 0, // TODO: 从日志数据计算
              ),
              loading: () => const CollectionStats(
                totalCats: 0,
                todayLogs: 0,
                streakDays: 0,
                isLoading: true,
              ),
              error: (_, __) => CollectionStats(
                totalCats: 0,
                todayLogs: 0,
                streakDays: 0,
                onTap: () => ref.invalidate(catCountProvider),
              ),
            ),
            const SizedBox(height: 24),

            // ====== 快速操作区域 ======
            const QuickActions(),
            const SizedBox(height: 24),

            // ====== 最近查看猫咪列表 ======
            catsAsync.when(
              data: (cats) {
                // 取最近查看的 5 只猫咪（按 lastSeenAt 降序）
                final recentCats = List<CatEntity>.from(cats)
                  ..sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
                final displayCats =
                    recentCats.take(5).toList();

                return RecentCats(
                  cats: displayCats,
                  onViewAll: () {
                    // 切换到图鉴 Tab
                    // 注意：由于 _HomeTab 是 const，无法直接访问父组件的 setState
                    // 这里使用 context 跳转到猫咪列表页面
                    context.push(RoutePaths.catList);
                  },
                );
              },
              loading: () => const RecentCats(
                cats: [],
                isLoading: true,
              ),
              error: (_, __) => const RecentCats(
                cats: [],
              ),
            ),

            // 底部留白（避免被 FAB 遮挡）
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.addCat),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// 图鉴 Tab
class _CatListTab extends StatelessWidget {
  const _CatListTab();

  @override
  Widget build(BuildContext context) {
    return const CatListPage();
  }
}

/// 日历 Tab
class _CalendarTab extends StatelessWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    return const CalendarPage();
  }
}

/// 成就 Tab
class _AchievementTab extends StatelessWidget {
  const _AchievementTab();

  @override
  Widget build(BuildContext context) {
    return const AchievementPage();
  }
}

/// 设置 Tab
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}
