import 'package:flutter/material.dart';

/// 免责声明弹窗组件
/// 展示应用相关的法律声明、隐私政策等信息
class DisclaimerDialog extends StatelessWidget {
  /// 弹窗标题
  final String title;

  /// 免责声明内容
  final String content;

  /// 确认按钮文本
  final String confirmText;

  /// 取消按钮文本
  final String? cancelText;

  /// 确认回调
  final VoidCallback? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 是否必须滚动到底部才能确认
  final bool requireScrollToBottom;

  /// 是否显示复选框确认
  final bool showCheckbox;

  const DisclaimerDialog({
    super.key,
    this.title = '免责声明',
    required this.content,
    this.confirmText = '我已阅读并同意',
    this.cancelText = '不同意',
    this.onConfirm,
    this.onCancel,
    this.requireScrollToBottom = false,
    this.showCheckbox = false,
  });

  /// 显示免责声明弹窗
  static Future<bool?> show(
    BuildContext context, {
    String title = '免责声明',
    required String content,
    String confirmText = '我已阅读并同意',
    String? cancelText = '不同意',
    bool requireScrollToBottom = false,
    bool showCheckbox = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DisclaimerDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        requireScrollToBottom: requireScrollToBottom,
        showCheckbox: showCheckbox,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// 显示隐私政策弹窗
  static Future<bool?> showPrivacyPolicy(BuildContext context) {
    return show(
      context,
      title: '隐私政策',
      content: _privacyPolicyContent,
      confirmText: '我同意',
      cancelText: '不同意',
      showCheckbox: true,
    );
  }

  /// 显示用户协议弹窗
  static Future<bool?> showUserAgreement(BuildContext context) {
    return show(
      context,
      title: '用户协议',
      content: _userAgreementContent,
      confirmText: '我同意',
      cancelText: '不同意',
      showCheckbox: true,
    );
  }

  /// 显示数据使用说明弹窗
  static Future<bool?> showDataUsageDisclaimer(BuildContext context) {
    return show(
      context,
      title: '数据使用说明',
      content: _dataUsageContent,
      confirmText: '我知道了',
      cancelText: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 内容区域
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: _ScrollableContent(
                content: content,
                requireScrollToBottom: requireScrollToBottom,
                onScrolledToBottom: () {},
              ),
            ),

            const SizedBox(height: 20),

            // 复选框确认
            if (showCheckbox) ...[
              const _CheckboxConfirmation(),
              const SizedBox(height: 16),
            ],

            // 按钮区域
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelText != null)
                  TextButton(
                    onPressed: onCancel,
                    child: Text(cancelText!),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onConfirm,
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 隐私政策内容
  static const String _privacyPolicyContent = '''
感谢您使用猫迹 App！我们非常重视您的隐私保护。

1. 信息收集
我们仅收集为您提供服务所必需的信息，包括：
• 账号信息（昵称、头像）
• 位置信息（用于发现附近的猫咪）
• 设备信息（用于优化用户体验）

2. 信息使用
我们使用收集的信息用于：
• 提供、维护和改进服务
• 发送重要通知
• 防止欺诈和滥用行为

3. 信息共享
我们不会将您的个人信息出售给第三方。仅在以下情况下可能共享：
• 获得您的明确同意
• 法律法规要求
• 保护猫迹及其用户的权利和安全

4. 数据安全
我们采用行业标准的安全措施保护您的数据，包括加密存储和传输。

5. 联系我们
如有任何隐私相关问题，请通过设置页面联系我们。
''';

  /// 用户协议内容
  static const String _userAgreementContent = '''
欢迎使用猫迹 App！

1. 服务说明
猫迹是一款猫咪收集与分享应用，用户可以发现和收集虚拟猫咪。

2. 用户行为规范
• 请友善对待其他用户
• 不得发布违法违规内容
• 不得使用外挂或作弊工具
• 尊重他人的知识产权

3. 知识产权
猫迹 App 的所有内容（包括但不限于文字、图片、音频、视频等）的知识产权归猫迹团队所有。

4. 免责声明
• 我们尽力确保服务的连续性，但不保证服务不会中断
• 因网络、设备等问题导致的服务中断，我们不承担责任
• 用户因使用本服务而产生的任何损失，我们不承担责任

5. 协议修改
我们保留随时修改本协议的权利，修改后的协议将在应用内公布。
''';

  /// 数据使用说明
  static const String _dataUsageContent = '''
为了给您提供更好的服务，我们需要使用以下数据：

📍 位置信息
用于发现附近的猫咪，仅在您主动使用时获取。

📷 相机权限
用于拍摄猫咪照片和 AR 功能，仅在您主动使用时访问。

📁 存储权限
用于保存猫咪图片到本地相册，仅在您主动使用时访问。

🔔 通知权限
用于发送猫咪相关的提醒和活动通知。

我们承诺：
• 不会在后台偷偷收集数据
• 不会将数据出售给第三方
• 您可以随时在设置中关闭权限
''';
}

/// 可滚动内容组件
class _ScrollableContent extends StatefulWidget {
  final String content;
  final bool requireScrollToBottom;
  final VoidCallback onScrolledToBottom;

  const _ScrollableContent({
    required this.content,
    required this.requireScrollToBottom,
    required this.onScrolledToBottom,
  });

  @override
  State<_ScrollableContent> createState() => _ScrollableContentState();
}

class _ScrollableContentState extends State<_ScrollableContent> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_hasScrolledToBottom && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 20) {
        _hasScrolledToBottom = true;
        widget.onScrolledToBottom();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          widget.content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        ),
      ),
    );
  }
}

/// 复选框确认组件
class _CheckboxConfirmation extends StatefulWidget {
  const _CheckboxConfirmation();

  @override
  State<_CheckboxConfirmation> createState() => _CheckboxConfirmationState();
}

class _CheckboxConfirmationState extends State<_CheckboxConfirmation> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _checked,
          onChanged: (value) => setState(() => _checked = value ?? false),
        ),
        Expanded(
          child: Text(
            '我已仔细阅读并理解上述内容',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// 底部弹出式免责声明
class DisclaimerBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback? onConfirm;

  const DisclaimerBottomSheet({
    super.key,
    this.title = '免责声明',
    required this.content,
    this.confirmText = '我知道了',
    this.onConfirm,
  });

  /// 显示底部弹窗
  static Future<void> show(
    BuildContext context, {
    String title = '免责声明',
    required String content,
    String confirmText = '我知道了',
    VoidCallback? onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DisclaimerBottomSheet(
        title: title,
        content: content,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 拖动指示条
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // 标题
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // 内容
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 确认按钮
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
