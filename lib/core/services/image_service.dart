import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../utils/image_utils.dart';

/// 图片服务 — 压缩、存储、缩略图
class ImageService {
  static final ImageService _instance = ImageService._();
  factory ImageService() => _instance;
  ImageService._();

  final _uuid = const Uuid();

  /// 获取图片存储目录
  Future<Directory> get _photosDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  /// 获取缩略图存储目录
  Future<Directory> get _thumbnailsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory('${appDir.path}/thumbnails');
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }

  /// 压缩并保存图片
  /// 返回 {filePath, thumbnailPath, fileSize, width, height}
  Future<Map<String, dynamic>?> compressAndSave(
    File sourceFile, {
    String? customFileName,
    bool addWatermark = false,
    String? watermarkText,
  }) async {
    try {
      // 读取原图
      final bytes = await sourceFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      final originalWidth = image.width;
      final originalHeight = image.height;

      // 压缩
      if (image.width > AppConstants.maxImageWidth ||
          image.height > AppConstants.maxImageHeight) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? AppConstants.maxImageWidth : null,
          height: image.height > image.width ? AppConstants.maxImageHeight : null,
        );
      }

      // 添加水印
      if (addWatermark && watermarkText != null) {
        image = ImageUtils.addWatermark(image, watermarkText);
      }

      // 保存压缩图
      final photosDir = await _photosDir;
      final fileName = customFileName ?? '${_uuid.v4()}.jpg';
      final filePath = '${photosDir.path}/$fileName';
      final compressedBytes = img.encodeJpg(image, quality: AppConstants.imageQuality);
      final file = File(filePath);
      await file.writeAsBytes(compressedBytes);

      // 生成缩略图
      final thumbnail = img.copyResize(
        image,
        width: AppConstants.thumbnailSize,
      );
      final thumbDir = await _thumbnailsDir;
      final thumbPath = '${thumbDir.path}/thumb_$fileName';
      final thumbBytes = img.encodeJpg(thumbnail, quality: 70);
      await File(thumbPath).writeAsBytes(thumbBytes);

      return {
        'filePath': filePath,
        'thumbnailPath': thumbPath,
        'fileSize': compressedBytes.length,
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      debugPrint('ImageService.compressAndSave error: $e');
      return null;
    }
  }

  /// 删除图片
  Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // 同时删除缩略图
      final thumbPath = filePath.replaceFirst('/photos/', '/thumbnails/thumb_');
      final thumbFile = File(thumbPath);
      if (await thumbFile.exists()) {
        await thumbFile.delete();
      }
      return true;
    } catch (e) {
      debugPrint('ImageService.deleteImage error: $e');
      return false;
    }
  }

  /// 批量删除图片
  Future<void> deleteImages(List<String> paths) async {
    for (final path in paths) {
      await deleteImage(path);
    }
  }

  /// 获取图片文件
  Future<File?> getImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// 获取所有图片占用的存储空间
  Future<int> getTotalStorageSize() async {
    int total = 0;
    try {
      final photosDir = await _photosDir;
      if (await photosDir.exists()) {
        await for (final entity in photosDir.list()) {
          if (entity is File) {
            total += await entity.length();
          }
        }
      }
      final thumbDir = await _thumbnailsDir;
      if (await thumbDir.exists()) {
        await for (final entity in thumbDir.list()) {
          if (entity is File) {
            total += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('ImageService.getTotalStorageSize error: $e');
    }
    return total;
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
