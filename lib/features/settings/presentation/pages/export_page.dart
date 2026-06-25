import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';

/// 数据导出服务
/// 
/// 提供导出猫咪档案为PDF和ZIP格式的功能
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// 导出为PDF
  Future<String?> exportToPdf({
    required List<dynamic> cats,
    required String fileName,
  }) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pw.PageFormat.a4,
          header: (pw.Context ctx) {
            return pw.Header(
              title: '猫咪图鉴导出',
              margin: pw.EdgeInsets.all(20),
            );
          },
          build: (pw.Context ctx) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cats.map((cat) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        cat.displayName ?? '未命名',
                        style: const pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('品种: ${cat.breed?.displayName ?? '未知'}'),
                      pw.Text('毛色: ${cat.color?.displayName ?? '未知'}'),
                      pw.Text('性别: ${cat.gender?.name ?? '未知'}'),
                      pw.Divider(),
                    ],
                  );
                }).toList(),
              ),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// 导出为ZIP（包含照片和数据）
  Future<String?> exportToZip({
    required List<dynamic> cats,
    required Map<int, List<String>> photoPaths,
    required String fileName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zipFile = File('${dir.path}/$fileName.zip');
      
      // TODO: 使用 archive 包创建 ZIP
      // 包含：
      // - cat_data.json
      // - photos/ 目录下的所有照片
      
      return zipFile.path;
    } catch (e) {
      return null;
    }
  }

  /// 分享PDF
  Future<void> sharePdf(Uint8List pdfBytes) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: '猫咪档案.pdf');
  }
}

/// 数据导出页面
class ExportPage extends ConsumerWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导出数据'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExportOption(
            icon: Icons.picture_as_pdf,
            title: '导出 PDF',
            subtitle: '生成可打印的档案册',
            onTap: () => _exportPdf(context),
          ),
          _ExportOption(
            icon: Icons.archive,
            title: '导出 ZIP',
            subtitle: '备份所有数据和照片',
            onTap: () => _exportZip(context),
          ),
        ],
      ),
    );
  }

  void _exportPdf(BuildContext context) {
    // TODO: 调用服务导出
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF导出功能开发中')),
    );
  }

  void _exportZip(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ZIP导出功能开发中')),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}