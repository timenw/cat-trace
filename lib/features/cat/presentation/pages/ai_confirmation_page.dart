import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/ai_recognition_service.dart';
import '../../../cat/data/models/cat_dto.dart';
import '../providers/cat_providers.dart';

/// AI 识别结果确认页面
/// 
/// 显示 AI 识别出的品种、毛色、特征等信息，让用户确认后保存。
class AiConfirmationPage extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  
  const AiConfirmationPage({super.key, required this.imagePaths});
  
  @override
  ConsumerState<AiConfirmationPage> createState() => _AiConfirmationPageState();
}

class _AiConfirmationPageState extends ConsumerState<AiConfirmationPage> {
  late final CatDto _catDto;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    // 使用模拟结果
    _catDto = CatDto(
      breed: CatBreed.values[DateTime.now().millisecond % CatBreed.values.length],
      color: CatColor.values[DateTime.now().millisecond % CatColor.values.length],
      confidence: 0.85,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),
            _buildRecognitionResult(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/cat_placeholder.png',
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecognitionResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '品种识别',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: '品种', value: _catDto.breed.displayName),
            _InfoRow(label: '毛色', value: _catDto.color.displayName),
            _InfoRow(label: '置信度', value: _catDto.confidenceDisplayText),
            const SizedBox(height: 16),
            const Text(
              '识别仅供参考，可在详情页修改',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(),
                child: const Text(AppStrings.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _saveCat,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveCat() async {
    setState(() => _isSaving = true);
    try {
      final addCat = ref.read(addCatProvider);
      await addCat(_catDto.toEntity());
      if (mounted) {
        context.pop();
        context.pop(); // 返回到列表页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('猫咪添加成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

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
            width: 60,
            child: Text(label, style: TextStyle(color: AppColors.lightTextSecondary)),
          ),
          Text(value, style: TextStyle(color: AppColors.lightTextPrimary)),
        ],
      ),
    );
  }
}