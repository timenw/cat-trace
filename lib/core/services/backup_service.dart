import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../../features/cat/domain/enums/cat_breed.dart';
import '../../features/cat/domain/enums/cat_color.dart';
import '../../features/cat/domain/enums/tnr_status.dart';
import '../../features/cat/domain/enums/rarity.dart';
import '../../../core/database/schemas/cat_schema.dart';
import '../../../core/database/schemas/log_schema.dart';
import '../../../core/database/schemas/photo_schema.dart';
import '../../../core/database/schemas/achievement_schema.dart';
import 'image_service.dart';

/// 备份服务 — 本地备份与恢复
class BackupService {
  final Isar isar;
  final ImageService imageService;

  BackupService({required this.isar, required this.imageService});

  /// 创建备份
  Future<String> createBackup() async {
    try {
      final backupDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${backupDir.path}/backups/cat_trace_backup_$timestamp';
      final backupDir2 = Directory(backupPath);
      await backupDir2.create(recursive: true);

      // 导出数据为 JSON
      final cats = await isar.catSchemas.where().findAll();
      final logs = await isar.logSchemas.where().findAll();
      final photos = await isar.photoSchemas.where().findAll();
      final achievements = await isar.achievementSchemas.where().findAll();

      final backupData = {
        'version': 1,
        'timestamp': timestamp,
        'cats': cats.map((c) => _catToJson(c)).toList(),
        'logs': logs.map((l) => _logToJson(l)).toList(),
        'photos': photos.map((p) => _photoToJson(p)).toList(),
        'achievements': achievements.map((a) => _achievementToJson(a)).toList(),
      };

      // 写入 JSON
      final jsonFile = File('$backupPath/data.json');
      await jsonFile.writeAsString(jsonEncode(backupData));

      // 复制照片
      final photosDir = Directory('$backupPath/photos');
      await photosDir.create(recursive: true);
      for (final photo in photos) {
        final file = File(photo.filePath);
        if (await file.exists()) {
          await file.copy('${photosDir.path}/${photo.id}.jpg');
        }
      }

      // 打包为 Zip
      final zipPath = '$backupPath.zip';
      final archive = Archive();
      await for (final entity in backupDir2.list(recursive: true)) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          final relativePath = entity.path.substring(backupPath.length + 1);
          archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await File(zipPath).writeAsBytes(zipBytes);
      }

      return zipPath;
    } catch (e) {
      throw Exception('备份失败: $e');
    }
  }

  /// 恢复备份
  Future<void> restoreBackup(String zipPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 解压到临时目录
      final tempDir = await getTemporaryDirectory();
      final extractPath = '${tempDir.path}/restore_${DateTime.now().millisecondsSinceEpoch}';
      final extractDir = Directory(extractPath);
      await extractDir.create(recursive: true);

      for (final file in archive) {
        final filename = '$extractPath/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // 读取 JSON
      final jsonFile = File('$extractPath/data.json');
      if (await jsonFile.exists()) {
        final jsonStr = await jsonFile.readAsString();
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;

        // 恢复数据
        await isar.writeTxn(() async {
          // 清空现有数据
          await isar.catSchemas.clear();
          await isar.logSchemas.clear();
          await isar.photoSchemas.clear();
          await isar.achievementSchemas.clear();

          // 恢复猫咪
          final cats = (data['cats'] as List?) ?? [];
          for (final catData in cats) {
            final cat = CatSchema()
              ..nickname = catData['nickname']
              ..breed = CatBreed.values.firstWhere(
                (e) => e.name == catData['breed'],
                orElse: () => CatBreed.unknown,
              )
              ..color = CatColor.values.firstWhere(
                (e) => e.name == catData['color'],
                orElse: () => CatColor.unknown,
              )
              ..tnrStatus = TnrStatus.values.firstWhere(
                (e) => e.name == catData['tnrStatus'],
                orElse: () => TnrStatus.none,
              )
              ..rarity = Rarity.values.firstWhere(
                (e) => e.name == catData['rarity'],
                orElse: () => Rarity.common,
              )
              ..locationHint = catData['locationHint']
              ..notes = catData['notes']
              ..firstSeenAt = DateTime.fromMillisecondsSinceEpoch(catData['firstSeenAt'] ?? 0)
              ..lastSeenAt = DateTime.fromMillisecondsSinceEpoch(catData['lastSeenAt'] ?? 0)
              ..createdAt = DateTime.fromMillisecondsSinceEpoch(catData['createdAt'] ?? 0)
              ..updatedAt = DateTime.fromMillisecondsSinceEpoch(catData['updatedAt'] ?? 0);
            await isar.catSchemas.put(cat);
          }
        });
      }

      // 恢复照片
      final photosDir = Directory('$extractPath/photos');
      if (await photosDir.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        final targetDir = Directory('${appDir.path}/photos');
        await targetDir.create(recursive: true);
        await for (final entity in photosDir.list()) {
          if (entity is File) {
            await entity.copy('${targetDir.path}/${entity.path.split('/').last}');
          }
        }
      }
    } catch (e) {
      throw Exception('恢复失败: $e');
    }
  }

  Map<String, dynamic> _catToJson(CatSchema c) => {
    'id': c.id,
    'nickname': c.nickname,
    'breed': c.breed.name,
    'color': c.color.name,
    'gender': c.gender.name,
    'estimatedAgeMonths': c.estimatedAgeMonths,
    'tags': c.tags.toList(),
    'tnrStatus': c.tnrStatus.name,
    'rarity': c.rarity.name,
    'locationHint': c.locationHint,
    'latitude': c.latitude,
    'longitude': c.longitude,
    'firstSeenAt': c.firstSeenAt.millisecondsSinceEpoch,
    'lastSeenAt': c.lastSeenAt.millisecondsSinceEpoch,
    'createdAt': c.createdAt.millisecondsSinceEpoch,
    'updatedAt': c.updatedAt.millisecondsSinceEpoch,
    'isDeleted': c.isDeleted,
    'notes': c.notes,
  };

  Map<String, dynamic> _logToJson(LogSchema l) => {
    'id': l.id,
    'catId': l.catId,
    'type': l.type.name,
    'recordedAt': l.recordedAt.millisecondsSinceEpoch,
    'createdAt': l.createdAt.millisecondsSinceEpoch,
    'feedType': l.feedType?.name,
    'feedAmount': l.feedAmount?.name,
    'healthStatus': l.healthStatus?.name,
    'spiritScore': l.spiritScore,
    'furScore': l.furScore,
    'hasInjury': l.hasInjury,
    'injuryDescription': l.injuryDescription,
    'weightEstimate': l.weightEstimate,
    'notes': l.notes,
  };

  Map<String, dynamic> _photoToJson(PhotoSchema p) => {
    'id': p.id,
    'catId': p.catId,
    'logId': p.logId,
    'filePath': p.filePath,
    'thumbnailPath': p.thumbnailPath,
    'takenAt': p.takenAt.millisecondsSinceEpoch,
    'createdAt': p.createdAt.millisecondsSinceEpoch,
    'fileSize': p.fileSize,
    'width': p.width,
    'height': p.height,
    'hasWatermark': p.hasWatermark,
    'watermarkText': p.watermarkText,
  };

  Map<String, dynamic> _achievementToJson(AchievementSchema a) => {
    'id': a.id,
    'achievementId': a.achievementId,
    'name': a.name,
    'description': a.description,
    'icon': a.icon,
    'rarity': a.rarity.name,
    'isUnlocked': a.isUnlocked,
    'unlockedAt': a.unlockedAt?.millisecondsSinceEpoch,
    'progress': a.progress,
    'target': a.target,
    'category': a.category.name,
  };
}
