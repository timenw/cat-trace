import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 联系方式页面
/// 
/// 显示动保组织和绝育医院的联系信息
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系方式'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '动保志愿者',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildContacts(_volunteerContacts),
          const SizedBox(height: 24),
          const Text(
            '绝育医院',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildContacts(_hospitalContacts),
        ],
      ),
    );
  }

  List<Widget> _buildContacts(List<ContactInfo> contacts) {
    return contacts.map((c) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.phone),
          title: Text(c.name),
          subtitle: Text(c.description),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );
    }).toList();
  }
}

/// 联系信息
class ContactInfo {
  final String name;
  final String phone;
  final String description;

  ContactInfo(this.name, this.phone, this.description);
}

// 志愿者联系（可配置）
final _volunteerContacts = [
  ContactInfo('流浪猫关爱协会', '138-XXXX-XXXX', '提供TNR指导和协助'),
  ContactInfo('本地动保志愿者', '139-XXXX-XXXX', '捕捉笼具租赁'),
];

// 医院联系（可配置）
final _hospitalContacts = [
  ContactInfo('市宠物医院', '010-XXXX-XXXX', '专业绝育手术'),
  ContactInfo('区动物诊所', '010-XXXX-XXXX', '术后照顾'),
];