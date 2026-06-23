import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../providers/cat_providers.dart';

/// 添加/编辑猫咪页面
///
/// 用于添加新猫咪或编辑已有猫咪的信息。
/// 包含表单字段：昵称、品种、毛色、性别、年龄、特征标签等。
class AddEditCatPage extends ConsumerStatefulWidget {
  /// 编辑模式下的猫咪 ID，null 表示添加模式
  final int? catId;

  const AddEditCatPage({super.key, this.catId});

  @override
  ConsumerState<AddEditCatPage> createState() => _AddEditCatPageState();
}

class _AddEditCatPageState extends ConsumerState<AddEditCatPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();

  // 表单字段
  String _selectedBreed = 'unknown';
  String _selectedColor = 'unknown';
  String _selectedGender = 'unknown';
  String _selectedTnrStatus = 'none';
  DateTime _firstSeenAt = DateTime.now();
  DateTime _lastSeenAt = DateTime.now();

  bool _isLoading = false;
  bool get _isEditMode => widget.catId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadCatData();
    }
  }

  /// 加载已有猫咪数据（编辑模式）
  Future<void> _loadCatData() async {
    final cat = await ref.read(catDetailProvider(widget.catId!).future);
    if (cat != null && mounted) {
      setState(() {
        _nicknameController.text = cat.nickname ?? '';
        _notesController.text = cat.notes ?? '';
        _tagsController.text = cat.tags.join('、');
        _locationController.text = cat.locationHint ?? '';
        _ageController.text = cat.estimatedAgeMonths?.toString() ?? '';
        _selectedBreed = cat.breed.name;
        _selectedColor = cat.color.name;
        _selectedGender = cat.gender.name;
        _selectedTnrStatus = cat.tnrStatus.name;
        _firstSeenAt = cat.firstSeenAt;
        _lastSeenAt = cat.lastSeenAt;
      });
    }
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
            child: Text(
              AppStrings.save,
              style: const TextStyle(color: Colors.white),
            ),
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
              // 头像占位
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.lightCard,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 48,
                    color: AppColors.lightTextHint,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: 选择图片
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('添加照片'),
                ),
              ),
              const SizedBox(height: 24),

              // 昵称
              const Text(
                AppStrings.catNickname,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  hintText: '给猫咪起个名字吧',
                ),
              ),
              const SizedBox(height: 16),

              // 品种
              const Text(
                AppStrings.catBreed,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                decoration: const InputDecoration(hintText: '选择品种'),
                items: const [
                  DropdownMenuItem(value: 'unknown', child: Text('未知')),
                  DropdownMenuItem(
                      value: 'domesticShorthair', child: Text('中华田园猫')),
                  DropdownMenuItem(
                      value: 'domesticLonghair', child: Text('中华田园长毛猫')),
                  DropdownMenuItem(value: 'siamese', child: Text('暹罗猫')),
                  DropdownMenuItem(value: 'persian', child: Text('波斯猫')),
                  DropdownMenuItem(
                      value: 'britishShorthair', child: Text('英短')),
                  DropdownMenuItem(
                      value: 'americanShorthair', child: Text('美短')),
                  DropdownMenuItem(value: 'ragdoll', child: Text('布偶猫')),
                  DropdownMenuItem(
                      value: 'scottishFold', child: Text('折耳猫')),
                  DropdownMenuItem(value: 'maineCoon', child: Text('缅因猫')),
                  DropdownMenuItem(value: 'bengal', child: Text('孟加拉猫')),
                  DropdownMenuItem(
                      value: 'russianBlue', child: Text('俄罗斯蓝猫')),
                  DropdownMenuItem(value: 'mixed', child: Text('混种')),
                ],
                onChanged: (value) {
                  setState(() => _selectedBreed = value!);
                },
              ),
              const SizedBox(height: 16),

              // 毛色
              const Text(
                AppStrings.catColor,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(hintText: '选择毛色'),
                items: const [
                  DropdownMenuItem(value: 'unknown', child: Text('未知')),
                  DropdownMenuItem(value: 'orange', child: Text('橘猫')),
                  DropdownMenuItem(value: 'black', child: Text('黑猫')),
                  DropdownMenuItem(value: 'white', child: Text('白猫')),
                  DropdownMenuItem(value: 'tabby', child: Text('虎斑')),
                  DropdownMenuItem(value: 'calico', child: Text('三花')),
                  DropdownMenuItem(value: 'tuxedo', child: Text('奶牛')),
                  DropdownMenuItem(value: 'gray', child: Text('灰猫')),
                  DropdownMenuItem(value: 'cream', child: Text('奶油')),
                  DropdownMenuItem(
                      value: 'tortoiseshell', child: Text('玳瑁')),
                  DropdownMenuItem(value: 'bicolor', child: Text('双色')),
                  DropdownMenuItem(value: 'pointed', child: Text('重点色')),
                  DropdownMenuItem(value: 'mixed', child: Text('混色')),
                ],
                onChanged: (value) {
                  setState(() => _selectedColor = value!);
                },
              ),
              const SizedBox(height: 16),

              // 性别
              const Text(
                AppStrings.catGender,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'unknown', label: Text('未知')),
                  ButtonSegment(value: 'male', label: Text('公猫')),
                  ButtonSegment(value: 'female', label: Text('母猫')),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (selected) {
                  setState(() => _selectedGender = selected.first);
                },
              ),
              const SizedBox(height: 16),

              // 估算年龄
              const Text(
                AppStrings.catAge,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '估算月龄（如：12 表示 1 岁）',
                  suffixText: '个月',
                ),
              ),
              const SizedBox(height: 16),

              // TNR 状态
              const Text(
                AppStrings.catTnrStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'none', label: Text('未绝育')),
                  ButtonSegment(value: 'earTip', label: Text('已耳缺')),
                  ButtonSegment(value: 'neutered', label: Text('已绝育')),
                ],
                selected: {_selectedTnrStatus},
                onSelectionChanged: (selected) {
                  setState(() => _selectedTnrStatus = selected.first);
                },
              ),
              const SizedBox(height: 16),

              // 特征标签
              const Text(
                AppStrings.catTags,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: '用顿号分隔（如：亲人、大尾巴）',
                ),
              ),
              const SizedBox(height: 16),

              // 位置
              const Text(
                '发现位置',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: '如：东区花坛旁',
                ),
              ),
              const SizedBox(height: 16),

              // 备注
              const Text(
                '备注',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '补充备注信息...',
                ),
              ),
              const SizedBox(height: 32),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditMode ? '保存修改' : '添加猫咪'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: 构建 CatEntity 并调用 repository 保存
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? '保存成功' : '添加成功'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
