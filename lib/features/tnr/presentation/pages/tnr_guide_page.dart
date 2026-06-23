import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// TNR 科普页面
class TnrGuidePage extends StatelessWidget {
  const TnrGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TNR 科普'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部卡片
            Card(
              color: AppColors.primaryLight.withAlpha(30),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('🐱', style: TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '什么是 TNR？',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Trap-Neuter-Return\n捕捉-绝育-放归',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TNR 三步
            _StepCard(
              step: '1',
              title: 'Trap（捕捉）',
              description: '使用专业诱捕笼，安全捕捉流浪猫。请勿徒手捕捉，以免受伤。',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _StepCard(
              step: '2',
              title: 'Neuter（绝育）',
              description: '将猫咪送往正规宠物医院进行绝育手术。术后恢复期间需要照顾。',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _StepCard(
              step: '3',
              title: 'Return（放归）',
              description: '术后恢复后，将猫咪放归到原来的生活环境。已绝育的猫咪会更健康。',
              color: AppColors.accent,
            ),

            const SizedBox(height: 24),

            // 为什么 TNR
            Text(
              '为什么选择 TNR？',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ReasonTile(
              icon: '✅',
              text: '控制流浪猫数量，减少过度繁殖',
            ),
            _ReasonTile(
              icon: '✅',
              text: '改善流浪猫健康状况，延长寿命',
            ),
            _ReasonTile(
              icon: '✅',
              text: '减少流浪猫行为问题（打架、嚎叫）',
            ),
            _ReasonTile(
              icon: '✅',
              text: '比扑杀更人道，更有效的长期方案',
            ),

            const SizedBox(height: 24),

            // 免责声明
            Card(
              color: AppColors.warning.withAlpha(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          '免责声明',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '本应用不提供捕捉工具和指导。TNR 操作需要专业知识和经验，请联系当地动保组织或志愿者协助。请勿自行捕捉流浪猫，以免造成人身伤害或猫咪应激。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final Color color;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String icon;
  final String text;

  const _ReasonTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
