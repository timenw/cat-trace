import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_database.dart';
import '../../../core/database/schemas/cat_schema.dart';
import '../../../core/constants/app_colors.dart';

/// 测试工具页面
/// 
/// 用于开发阶段生成测试数据
class TestToolsPage extends ConsumerWidget {
  const TestToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('测试工具')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '生成测试数据',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _generateTestData(context),
                    child: const Text('生成5只测试猫咪'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _clearTestData(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('清空测试数据'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateTestData(BuildContext context) async {
    try {
      final isar = IsarDatabase.instance;
      final now = DateTime.now();
      
      final testCats = [
        CatSchema(
          nickname: '小橘',
          breed: 1, // domesticShorthair
          color: 1, // orange
          gender: 0, // unknown
          rarity: 1, // uncommon
          firstSeenAt: now.subtract(const Duration(days: 30)),
          lastSeenAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        CatSchema(
          nickname: '三花妹妹',
          breed: 0, // unknown
          color: 4, // calico
          gender: 1, // female
          rarity: 2, // rare
          firstSeenAt: now.subtract(const Duration(days: 15)),
          lastSeenAt: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        CatSchema(
          nickname: '黑脸大哥',
          breed: 0,
          color: 2, // black
          gender: 0, // male
          tnrStatus: 2, // neutered
          rarity: 2, // rare
          firstSeenAt: now.subtract(const Duration(days: 45)),
          lastSeenAt: now.subtract(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 45)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      await isar.writeTxn(() async {
        await isar.collection<CatSchema>().putAll(testCats);
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测试数据生成成功')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    }
  }

  Future<void> _clearTestData(BuildContext context) async {
    try {
      final isar = IsarDatabase.instance;
      await isar.writeTxn(() async {
        await isar.collection<CatSchema>().clear();
      });
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据已清空')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清空失败: $e')),
      );
    }
  }
}