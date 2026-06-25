import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/permission_utils.dart';

/// 照片选择组件
/// 
/// 支持拍照和相册选择，显示已选图片缩略图，
/// 可选触发 AI 识别
class PhotoSelectorWidget extends ConsumerStatefulWidget {
  final List<String> selectedImages;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback? onRecognize;
  
  const PhotoSelectorWidget({
    super.key,
    required this.selectedImages,
    required this.onChanged,
    this.onRecognize,
  });

  @override
  ConsumerState<PhotoSelectorWidget> createState() => _PhotoSelectorWidgetState();
}

class _PhotoSelectorWidgetState extends ConsumerState<PhotoSelectorWidget> {
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: _isPicking ? null : _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('从相册选择'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _isPicking ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
            ),
            if (widget.onRecognize != null && widget.selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onRecognize,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI识别'),
              ),
            ],
          ],
        ),
        if (widget.selectedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(widget.selectedImages[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final newImages = List<String>.from(widget.selectedImages)
                              ..removeAt(index);
                            widget.onChanged(newImages);
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImages() async {
    setState(() => _isPicking = true);
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final paths = images.map((e) => e.path).toList();
        widget.onChanged([...widget.selectedImages, ...paths]);
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isPicking = true);
    try {
      final result = await PermissionUtils.requestCameraPermission();
      if (result != PermissionResult.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要相机权限才能拍照')),
        );
        return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        widget.onChanged([...widget.selectedImages, image.path]);
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }
}