import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../domain/entities/cat_entity.dart';
import '../providers/cat_providers.dart';
import '../widgets/cat_header.dart';
import '../widgets/photo_timeline.dart';

/// 猫咪详情页
///
/// 展示单只猫咪的详细信息，包括基本信息、TNR 状态、照片时间线等。
/// 支持编辑和添加日志操作。
class CatDetailPage extends ConsumerWidget {
  /// 猫咪 ID
  final int catId;

  const CatDetailPage({super.key, required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catDetailProvider(catId));

    return catAsync.when(
      data: (cat) {
        if (cat == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('猫咪详情')),
            body: const Center(
              child: Text('找不到这只猫咪'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(cat.displayName),
            actions: [
              // 编辑按钮
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/cats/${cat.id}/edit'),
              ),
              // 更多操作
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'delete':
                      _showDeleteDialog(context, ref, cat.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('删除'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部区域（头像 + 基本信息）
                CatHeader(cat: cat),

                const Divider(height: 1),

                // 基本信息
                _buildInfoSection(context, cat),

                const Divider(height: 1),

                // 照片时间线
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PhotoTimeline(catId: cat.id),
                ),

                const Divider(height: 1),

                // 观察记录
                _buildLogSection(context, cat.id),

                // 底部安全间距
                const SizedBox(height: 80),
              ],
            ),
          ),
          // 悬浮操作按钮
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/cats/${cat.id}/logs/add'),
            icon: const Icon(Icons.add),
            label: const Text('记录'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('加载中...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('出错了')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(catDetailProvider(catId)),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建基本信息区域
  Widget _buildInfoSection(BuildContext context, CatEntity cat) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: AppStrings.catBreed, value: cat.breed.displayName),
          _InfoRow(label: AppStrings.catColor, value: cat.color.displayName),
          _InfoRow(
            label: AppStrings.catGender,
            value: _getGenderText(cat.gender),
          ),
          _InfoRow(label: AppStrings.catAge, value: cat.ageDisplayText),
          _InfoRow(label: AppStrings.catTnrStatus, value: cat.tnrStatus.displayName),
          if (cat.locationHint != null)
            _InfoRow(label: '位置', value: cat.locationHint!),
          if (cat.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              '特征标签',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: cat.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      ))
                  .toList(),
            ),
          ],
          if (cat.notes != null) ...[
            const SizedBox(height: 12),
            const Text(
              '备注',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cat.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建观察记录区域
  Widget _buildLogSection(BuildContext context, int catId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '观察记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/cats/$catId/logs/add'),
                child: const Text('添加记录'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 空状态
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.note_alt, size: 32, color: AppColors.lightTextHint),
                SizedBox(height: 8),
                Text(
                  '暂无观察记录',
                  style: TextStyle(color: AppColors.lightTextHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认弹窗
  void _showDeleteDialog(BuildContext context, WidgetRef ref, int catId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这只猫咪的记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              // TODO: 执行删除操作
              Navigator.of(context).pop();
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  /// 获取性别显示文本
  String _getGenderText(dynamic gender) {
    switch (gender.toString()) {
      case 'CatGender.male':
        return '公猫';
      case 'CatGender.female':
        return '母猫';
      default:
        return '未知';
    }
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
