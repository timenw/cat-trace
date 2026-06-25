import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cat/domain/entities/cat_entity.dart';
import '../providers/cat_providers.dart';

/// 手动添加/编辑猫咪页面
class ManualAddCatPage extends ConsumerStatefulWidget {
  final int? catId;
  
  const ManualAddCatPage({super.key, this.catId});

  @override
  ConsumerState<ManualAddCatPage> createState() => _ManualAddCatPageState();
}

class _ManualAddCatPageState extends ConsumerState<ManualAddCatPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedBreed = 'unknown';
  String _selectedColor = 'unknown';
  String _selectedGender = 'unknown';
  String _selectedTnrStatus = 'none';
  List<String> _selectedPhotoPaths = [];

  bool _isLoading = false;
  bool get _isEditMode => catId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _loadCatData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑猫咪' : '添加猫咪'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 24),
              _buildField(
                label: '昵称',
                hint: '给猫咪起个名字吧',
                controller: _nicknameController,
              ),
              _buildDropdown('品种', _selectedBreed, _breedOptions, (v) {
                setState(() => _selectedBreed = v);
              }),
              _buildDropdown('毛色', _selectedColor, _colorOptions, (v) {
                setState(() => _selectedColor = v);
              }),
              _buildGenderSelector(),
              _buildAgeField(),
              _buildTnrSelector(),
              _buildField(
                label: '特征标签',
                hint: '用顿号分隔（如：亲人、大尾巴）',
                controller: _tagsController,
              ),
              _buildField(
                label: '发现位置',
                hint: '如：东区花坛旁',
                controller: _locationController,
              ),
              _buildField(
                label: '备注',
                hint: '补充备注信息...',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditMode ? '保存修改' : '添加猫咪'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('照片', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedPhotoPaths.asMap().entries.map((e) {
              final idx = e.key;
              final path = e.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPhotoPaths.removeAt(idx)),
                      child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _addPhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_photo_alternate),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(hintText: '选择$label'),
          items: items,
          onChanged: (v) => onChanged(v!),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'unknown', label: Text('未知')),
            ButtonSegment(value: 'male', label: Text('公猫')),
            ButtonSegment(value: 'female', label: Text('母猫')),
          ],
          selected: {_selectedGender},
          onSelectionChanged: (s) => setState(() => _selectedGender = s.first),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAgeField() {
    return _buildField(
      label: '估算年龄',
      hint: '月龄（如：12）',
      controller: _ageController,
      maxLines: 1,
    );
  }

  Widget _buildTnrSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TNR状态', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'none', label: Text('未绝育')),
            ButtonSegment(value: 'earTip', label: Text('已耳缺')),
            ButtonSegment(value: 'neutered', label: Text('已绝育')),
          ],
          selected: {_selectedTnrStatus},
          onSelectionChanged: (s) => setState(() => _selectedTnrStatus = s.first),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _selectedPhotoPaths.add(img.path));
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCatData() async {}

  static const _breedOptions = [
    DropdownMenuItem(value: 'unknown', child: Text('未知')),
    DropdownMenuItem(value: 'domesticShorthair', child: Text('中华田园猫')),
    DropdownMenuItem(value: 'siamese', child: Text('暹罗猫')),
    DropdownMenuItem(value: 'persian', child: Text('波斯猫')),
    DropdownMenuItem(value: 'britishShorthair', child: Text('英短')),
    DropdownMenuItem(value: 'mixed', child: Text('混种')),
  ];

  static const _colorOptions = [
    DropdownMenuItem(value: 'unknown', child: Text('未知')),
    DropdownMenuItem(value: 'orange', child: Text('橘猫')),
    DropdownMenuItem(value: 'black', child: Text('黑猫')),
    DropdownMenuItem(value: 'white', child: Text('白猫')),
    DropdownMenuItem(value: 'tabby', child: Text('虎斑')),
    DropdownMenuItem(value: 'calico', child: Text('三花')),
    DropdownMenuItem(value: 'tuxedo', child: Text('奶牛')),
  ];
}