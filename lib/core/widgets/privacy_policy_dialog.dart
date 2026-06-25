import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';

/// 隐私政策弹窗
/// 
/// 首次启动显示，用户需接受才能继续使用
class PrivacyPolicyDialog extends ConsumerWidget {
  final VoidCallback onAccepted;

  const PrivacyPolicyDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.privacy_tip, color: AppColors.primary),
          SizedBox(width: 8),
          Text('隐私政策'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '猫匿（MiaoNi）尊重您的隐私',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. 所有数据默认存储在设备本地，不会上传到服务器\n'
              '2. 照片仅用于猫咪档案，不会用于其他用途\n'
              '3. 位置信息（如启用）会模糊化处理，仅记录区域\n'
              '4. 若使用云备份功能，数据将加密后存储\n'
              '5. 点击照片可添加时间+随机ID水印\n'
              '6. 您可随时清空所有数据',
            ),
            const SizedBox(height: 12),
            Text(
              '此应用不提供捕捉工具，如需TNR请联系专业志愿者',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _accept(context),
          child: const Text('我知道了，继续使用'),
        ),
      ],
    );
  }

  Future<void> _accept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_accepted', true);
    onAccepted();
  }
}

/// 检查隐私政策是否已接受
Future<bool> isPrivacyAccepted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('privacy_accepted') ?? false;
}