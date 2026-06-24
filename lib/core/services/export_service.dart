import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../database/schemas/cat_schema.dart';
import '../database/schemas/log_schema.dart';

/// 导出服务 — 导出 PDF/Zip
class ExportService {
  final Isar isar;
  ExportService({required this.isar});

  /// 导出所有数据为 Zip
  Future<String> exportAllAsZip() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath = '${appDir.path}/exports/cat_trace_export_$timestamp';
      final exportDir = Directory(exportPath);
      await exportDir.create(recursive: true);

      // 导出数据为 JSON
      final cats = await isar.collection<CatSchema>().where().findAll();
      final logs = await isar.collection<LogSchema>().where().findAll();

      final exportData = {
        'app': 'CatTrace',
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'cats': cats.map((c) => _catToJson(c)).toList(),
        'logs': logs.map((l) => _logToJson(l)).toList(),
      };

      // 写入 JSON
      final jsonFile = File('$exportPath/cat_trace_data.json');
      await jsonFile.writeAsString(jsonEncode(exportData));

      // 复制照片
      final photosDir = Directory('$exportPath/photos');
      await photosDir.create(recursive: true);
      for (final _ in cats) {
        final catPhotosDir = Directory('${appDir.path}/photos');
        if (await catPhotosDir.exists()) {
          await for (final entity in catPhotosDir.list()) {
            if (entity is File) {
              await entity.copy('${photosDir.path}/${entity.path.split('/').last}');
            }
          }
        }
      }

      // 打包为 Zip
      final zipPath = '$exportPath.zip';
      final archive = Archive();
      await for (final entity in exportDir.list(recursive: true)) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          final relativePath = entity.path.substring(exportPath.length + 1);
          archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await File(zipPath).writeAsBytes(zipBytes);
      }

      return zipPath;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  /// 导出单只猫咪档案为 PDF（简化版，生成 HTML 后转 PDF）
  Future<String> exportCatProfile(int catId) async {
    try {
      final cat = await isar.collection<CatSchema>().filter().idEqualTo(catId).findFirst();
      if (cat == null) throw Exception('找不到猫咪');

      final logs = await isar.collection<LogSchema>().filter().catIdEqualTo(catId).sortByRecordedAtDesc().findAll();

      // 生成 HTML
      final html = _generateCatHtml(cat, logs);

      // 保存 HTML（实际项目中可使用 pdf 包转换为 PDF）
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final htmlPath = '${appDir.path}/exports/cat_${cat.nickname ?? catId}_$timestamp.html';
      final htmlFile = File(htmlPath);
      await htmlFile.create(recursive: true);
      await htmlFile.writeAsString(html);

      return htmlPath;
    } catch (e) {
      throw Exception('导出档案失败: $e');
    }
  }

  String _generateCatHtml(CatSchema cat, List<LogSchema> logs) {
    final buffer = StringBuffer();
    buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>猫咪档案 - ${cat.nickname ?? '未命名'}</title>
  <style>
    body { font-family: sans-serif; padding: 20px; }
    h1 { color: #FF8A65; }
    .info { margin: 10px 0; }
    .label { font-weight: bold; color: #666; }
    .log { border-left: 3px solid #FF8A65; padding: 10px; margin: 10px 0; }
  </style>
</head>
<body>
  <h1>🐱 ${cat.nickname ?? '未命名'}</h1>
  <div class="info"><span class="label">品种:</span> ${cat.breed.displayName}</div>
  <div class="info"><span class="label">毛色:</span> ${cat.color.displayName}</div>
  <div class="info"><span class="label">TNR状态:</span> ${cat.tnrStatus.displayName}</div>
  <div class="info"><span class="label">首次发现:</span> ${cat.firstSeenAt.toString().split(' ')[0]}</div>
  <div class="info"><span class="label">最近观察:</span> ${cat.lastSeenAt.toString().split(' ')[0]}</div>
  ${cat.notes != null ? '<div class="info"><span class="label">备注:</span> ${cat.notes}</div>' : ''}
  <h2>📝 日志记录 (${logs.length})</h2>
''');

    for (final log in logs) {
      buffer.writeln('''
  <div class="log">
    <div><span class="label">${log.type.displayName}</span> - ${log.recordedAt.toString().split('.')[0]}</div>
    ${log.notes != null ? '<div>${log.notes}</div>' : ''}
  </div>
''');
    }

    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  Map<String, dynamic> _catToJson(CatSchema c) => {
    'id': c.id,
    'nickname': c.nickname,
    'breed': c.breed.displayName,
    'color': c.color.displayName,
    'gender': c.gender.name,
    'estimatedAgeMonths': c.estimatedAgeMonths,
    'tags': c.tags.toList(),
    'tnrStatus': c.tnrStatus.displayName,
    'rarity': c.rarity.displayName,
    'locationHint': c.locationHint,
    'firstSeenAt': c.firstSeenAt.toIso8601String(),
    'lastSeenAt': c.lastSeenAt.toIso8601String(),
    'notes': c.notes,
  };

  Map<String, dynamic> _logToJson(LogSchema l) => {
    'id': l.id,
    'catId': l.catId,
    'type': l.type.displayName,
    'recordedAt': l.recordedAt.toIso8601String(),
    'feedType': l.feedType.displayName,
    'feedAmount': l.feedAmount.name,
    'healthStatus': l.healthStatus.displayName,
    'spiritScore': l.spiritScore,
    'furScore': l.furScore,
    'hasInjury': l.hasInjury,
    'injuryDescription': l.injuryDescription,
    'weightEstimate': l.weightEstimate,
    'notes': l.notes,
  };
}
