import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/ai_recognition_service.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../cat/data/models/cat_dto.dart';
import '../providers/cat_providers.dart';

/// 照片识别页面
/// 
/// 拍照或选择照片后进行AI品种识别
class RecognizeCatPage extends ConsumerStatefulWidget {
  const RecognizeCatPage({super.key});

  @override
  ConsumerState<RecognizeCatPage> createState() => _RecognizeCatPageState();
}

class _RecognizeCatPageState extends ConsumerState<RecognizeCatPage> {
  List<String> _selectedImages = [];
  BreedRecognitionResult? _recognitionResult;
  bool _isRecognizing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI识别')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 24),
            if (_recognitionResult != null) _buildResultSection(),
            if (_isRecognizing) _buildRecognizingIndicator(),
          ],
        ),
      ),
      floatingActionButton: _selectedImages.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isRecognizing ? null : _recognizeBreed,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('开始识别'),
            )
          : null,
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/cat_placeholder.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                          _recognitionResult = null;
                        });
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightTextHint.withOpacity(0.3)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 32),
                    SizedBox(height: 4),
                    Text('添加', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    final result = _recognitionResult!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '识别结果',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: '品种', value: result.breedName),
            _InfoRow(label: '置信度', value: '${(result.confidence * 100).toStringAsFixed(1)}%'),
            if (result.description != null) ...[
              const SizedBox(height: 8),
              Text(
                result.description!,
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(_recognitionResult),
              child: const Text('确认并添加到图鉴'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognizingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在识别...'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _recognizeBreed() async {
    setState(() => _isRecognizing = true);
    
    try {
      final service = AiRecognitionService();
      await service.initialize();
      
      // 使用模拟识别（实际项目中应读取图片字节）
      final result = await service.recognizeBreed(Uint8List(0));
      
      if (mounted && result != null) {
        setState(() => _recognitionResult = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecognizing = false);
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
            width: 80,
            child: Text(label, style: TextStyle(color: AppColors.lightTextSecondary)),
          ),
          Text(value),
        ],
      ),
    );
  }