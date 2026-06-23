import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/cat_providers.dart';
import '../widgets/cat_card.dart';

/// 猫咪列表页
///
/// 以卡片网格形式展示所有已记录的猫咪。
/// 支持搜索、筛选和排序功能。
class CatListPage extends ConsumerWidget {
  /// 是否为嵌入模式（在首页 Tab 中显示时隐藏 AppBar）
  final bool embeddedMode;

  const CatListPage({super.key, this.embeddedMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(catsProvider);

    return Scaffold(
      appBar: embeddedMode
          ? null
          : AppBar(
              title: const Text('猫咪图鉴'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: 打开搜索
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: 打开筛选
                  },
                ),
              ],
            ),
      body: catsAsync.when(
        data: (cats) {
          if (cats.isEmpty) {
            // 空状态
            return _buildEmptyState(context);
          }
          // 网格列表
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(catsProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                return CatCard(
                  cat: cats[index],
                  onTap: () {
                    context.push('/cats/${cats[index].id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, error, ref),
      ),
      floatingActionButton: embeddedMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(RoutePaths.addCat),
              child: const Icon(Icons.add),
            ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.lightTextHint.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有记录猫咪',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右下角按钮添加第一只猫咪吧',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextHint,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(RoutePaths.addCat),
              icon: const Icon(Icons.add),
              label: const Text('添加猫咪'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.error,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.lightTextHint,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(catsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
