import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// 照片时间线组件
///
/// 在猫咪详情页中展示照片的历史时间线。
/// 按时间倒序排列，支持添加新照片。
class PhotoTimeline extends ConsumerWidget {
  /// 猫咪 ID
  final int catId;

  const PhotoTimeline({super.key, required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 从 provider 获取照片列表
    final photos = <_PhotoItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '照片时间线',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 添加照片
              },
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('添加照片'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 照片列表或空状态
        if (photos.isEmpty)
          _buildEmptyState()
        else
          _buildPhotoGrid(photos),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppColors.lightTextHint.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            '还没有照片',
            style: TextStyle(
              color: AppColors.lightTextHint,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '记录猫咪的可爱瞬间吧',
            style: TextStyle(
              color: AppColors.lightTextHint.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建照片网格
  Widget _buildPhotoGrid(List<_PhotoItem> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onTap: () {
            // TODO: 查看大图
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, color: AppColors.lightTextHint),
                  const SizedBox(height: 4),
                  Text(
                    photo.dateText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.lightTextHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 照片项（临时数据结构）
class _PhotoItem {
  final String url;
  final DateTime takenAt;

  _PhotoItem({required this.url, required this.takenAt});

  String get dateText =>
      '${takenAt.year}/${takenAt.month.toString().padLeft(2, '0')}';
}
